package org.jasm.resolver;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jasm.item.AbstractByteCodeItem;
import org.jasm.item.clazz.Clazz;
import org.jasm.parser.literals.SymbolReference;
import org.jasm.type.descriptor.TypeDescriptor;

public class ClassInfoResolver  {
	
	private List<IClassPathEntry> entries = new ArrayList<IClassPathEntry>();
	
	private Map<String, AbstractInfo> classCache = new HashMap<String, AbstractInfo>();
	private Map<String, Boolean> classAccessCache = new HashMap<String, Boolean>();
	private Map<String, AbstractInfo> fieldCache = new HashMap<String, AbstractInfo>();
	private Map<String, Boolean> fieldAccessCache = new HashMap<String, Boolean>();
	private Map<String, AbstractInfo> methodCache = new HashMap<String, AbstractInfo>();
	private Map<String, Boolean> methodAccessCache = new HashMap<String, Boolean>();
	
	
	
	public ExternalClassInfo resolve(Clazz clazz, AbstractByteCodeItem caller, SymbolReference symbol, String className, boolean checkAccess)  {
		
		if (classCache.containsKey(className)) {
			AbstractInfo info = classCache.get(className);
			if (info == NotFoundInfo.VALUE) {
				return null;
			} else {
				return (ExternalClassInfo)info;
			}
		}
		
		ExternalClassInfo result = null;
		
		if (className.startsWith("[")) {
			result =  resolveArray(clazz, caller, symbol, className);
			if (result == null) {
				classCache.put(className, NotFoundInfo.VALUE);
			} else {
				classCache.put(className, result);
			}
		} else {
			result =  resolveClass(clazz, caller, symbol, className);
			if (result == null) {
				classCache.put(className, NotFoundInfo.VALUE);
			} else {
				classCache.put(className, result);
			}
			if (result !=null && checkAccess) {
				String accessKey = clazz.getThisClass().getClassName()+"->"+className;
				if (classAccessCache.containsKey(accessKey)) {
					if (!classAccessCache.get(accessKey)) {
						result = null;
					}
				} else {
					if (result.getModifier().isPublic()) {
						classAccessCache.put(accessKey, true);
					} else {
						if (clazz.getPackage().equals(result.getPackage())) {
							classAccessCache.put(accessKey, true);
						} else {
							caller.emitError(symbol, "tried illegal access for "+result.name);
							classAccessCache.put(accessKey, false);
							result = null;
						}
					}
				}
			}
		}
		return result;
		
	}
	
	private ExternalClassInfo resolveArray(Clazz clazz, AbstractByteCodeItem caller, SymbolReference symbol, String className) {
		ExternalClassInfo result = new ExternalClassInfo();
		TypeDescriptor desc = new TypeDescriptor(className);
		result.descriptor = desc;
		result.superName = "java/lang/Object";
		ExternalClassInfo superInfo = resolve(clazz, caller, symbol, result.superName, false);
		if (superInfo != null) {
			result.superClass = superInfo;
			if (desc.getComponentType().isArray() || desc.getComponentType().isObject()) {
				if (desc.getComponentType().isArray()) {
					result.componentClass = resolve(clazz, caller, symbol, desc.getComponentType().getValue(), true);
				} else {
					result.componentClass = resolve(clazz, caller, symbol, desc.getComponentType().getComponentClassName(), true);
				}
				if (result.componentClass != null) {
					return result;
				} else {
					return null;
				}
			} else {
				return result;
			}
		} else {
			return null;
		}
		
	}
	
	private ExternalClassInfo resolveClass(Clazz clazz, AbstractByteCodeItem caller, SymbolReference symbol, String className) {
		ExternalClassInfo result = findClass(className);
		if (result == null) {
			caller.emitError(symbol, "unknown class "+className);
			return null;
		} else {
			if (result.superName != null) {
				ExternalClassInfo superInfo = resolve(clazz, caller, symbol, result.superName, false);
				if (superInfo != null) {
					result.superClass = superInfo;
				} else {
					return null;
				}
			}
			for (String name: result.interfacesNames) {
				ExternalClassInfo intfInfo = resolve(clazz, caller, symbol, name, false);
				if (intfInfo != null) {
					result.interfaces.add(intfInfo);
				} else {
					return null;
				}
			}
			return result;
		}
	}
	
	ExternalClassInfo findClass(String className) {
		for (IClassPathEntry entry: entries) {
			if (!entry.isInvalid()) {
				ExternalClassInfo info = entry.findClass(className);
				if (info != null) {
					return info;
				}
			}
		}
		return null;
	}
	
	private AbstractInfo resolveMember(Clazz clazz, AbstractByteCodeItem caller, SymbolReference symbol, String className,String name,  String descriptor,boolean checkAccess, Map<String, AbstractInfo> memberCache, Map<String, Boolean> memberAccessCache, MemberFindAndAccess mfa, String label) {
		String memberKey = className+"."+name+"@"+descriptor;
		if (memberCache.containsKey(memberKey)) {
			AbstractInfo info = memberCache.get(className);
			if (info == NotFoundInfo.VALUE) {
				return null;
			} else {
				return info;
			}
		}
		ExternalClassInfo cli = resolve(clazz, caller, symbol, className, checkAccess);
		AbstractInfo result = null;
		if (cli != null) {
			result = mfa.findMember(cli, name, descriptor);
			if (result == null) {
				memberCache.put(memberKey, NotFoundInfo.VALUE);
			} else {
				memberCache.put(memberKey, result);
			}
			if (result != null) {
				if (checkAccess) {
					String accessKey = clazz.getThisClass().getClassName()+"->"+memberKey;
					if (memberAccessCache.containsKey(accessKey)) {
						if (!memberAccessCache.get(accessKey)) {
							result = null;
						}
					} else {
						if (mfa.checkAccess(clazz, cli,result)) {
							memberAccessCache.put(accessKey, true);
							return result;
						} else {
							memberAccessCache.put(accessKey, false);
							caller.emitError(symbol, "lllegal access for "+cli.getName()+"."+name+"@"+descriptor);
							result = null;
						}
					}
				} else {
					return result;
				}
			} else {
				caller.emitError(symbol, "unknown "+label+" "+cli.getName()+"."+name+"@"+descriptor);
				return null;
			}
		} else {
			memberCache.put(memberKey, NotFoundInfo.VALUE);
		}
		return result;
	}
	
	public FieldInfo resolveField(Clazz clazz, AbstractByteCodeItem caller, SymbolReference symbol, String className,String name,  String descriptor,boolean checkAccess)  {
		MemberFindAndAccess mfa = new MemberFindAndAccess() {
			
			@Override
			public AbstractInfo findMember(ExternalClassInfo cli, String name,
					String descriptor) {
				return findField(cli, name, descriptor);
			}
			
			@Override
			public boolean checkAccess(Clazz clazz, ExternalClassInfo requestClass,
					AbstractInfo member) {
				return checkFieldAccess(clazz, requestClass, (FieldInfo)member);
			}
			
			
		};
		
		return (FieldInfo)resolveMember(clazz, caller, symbol, className, name, descriptor, checkAccess, fieldCache, fieldAccessCache, mfa, "field");
		
	}
	
	private FieldInfo findField(ExternalClassInfo cli, String name, String descriptor) {
		
		
		FieldInfo info = cli.getField(name, descriptor);
		if (info != null) {
			return info;
		} else {
			int i=0;
			for (ExternalClassInfo intf: cli.getInterfaces()) {
				info = findField(intf, name, descriptor);
				if (info != null) {
					return info;
				}
				i++;
			}
			if (cli.getSuperClass() != null) {
				info = findField(cli.getSuperClass(), name, descriptor);
				if (info != null) {
					return info;
				} else {
					return null;
				}
			} else {
				return null;
			}
		}
	}
	
	private boolean checkFieldAccess(Clazz clazz, ExternalClassInfo requestClass, FieldInfo fi) {
		
		ExternalClassInfo me = clazz.getMe();
		String declarationClass = fi.getParent().getName();
		
		if (fi.getModifier().isPublic()) {
			return true;
		} else if (fi.getModifier().isProtected() && me.isDerivedFrom(declarationClass)){
			if (fi.getModifier().isStatic()) {
				return true;
			} else {
				if (me.isDerivedFrom(requestClass.getName()) || requestClass.isDerivedFrom(me.getName())) {
					return true;
				} else {
					return fi.getParent().getPackage().equals(me.getPackage());
				}
			}
		} else if ((fi.getModifier().isProtected() 
					|| (!fi.getModifier().isPublic() && !fi.getModifier().isProtected() && !fi.getModifier().isPrivate()))
					&& fi.getParent().getPackage().equals(me.getPackage())
		          ) {
			
		  return true;
			
		} else if (fi.getModifier().isPrivate() && me.equals(fi.getParent()) ) {
			return true;
		}
		
		return false;
	}
	
	
	
	
	public void add(IClassPathEntry entry) {
		entries.add(entry);
	}
	
	public void addAtBegin(IClassPathEntry entry) {
		entries.add(0, entry);
	}
}

interface MemberFindAndAccess {
	AbstractInfo findMember(ExternalClassInfo cli, String name, String descriptor);
	boolean checkAccess(Clazz clazz, ExternalClassInfo requestClass, AbstractInfo member);
}
