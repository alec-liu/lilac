package org.jasm.test.testclass;

public abstract class Class2  {
	
	public static String staticString = "HELLO WORLD";
	
	private final int finalIntField = 0;
	
	protected transient Boolean transientField = false;
	
	
	
	private void privateMethod(int a) {
	}
	
	protected abstract void protectedAbstractMethod();
	
	synchronized static void synchronizedStaticMethod() {
		
	}
	

}
