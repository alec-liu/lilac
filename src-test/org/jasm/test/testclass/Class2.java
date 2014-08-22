package org.jasm.test.testclass;

public abstract class Class2  {
	
	public static String staticString = "HELLO WORLD";
	
	private final int finalIntField = 0;
	
	protected transient Boolean transientField = false;
	
	public static final int constInt = 1;
	
	
	@Deprecated
	private void privateMethod(int a) {
	}
	
	protected abstract void protectedAbstractMethod();
	
	synchronized static void synchronizedStaticMethod() {
		
	}
	
	public void methodMitException() throws IllegalArgumentException {
		throw new IllegalArgumentException("XXX");
	}
	
	protected void methodWithAnonymousClass() {
		Runnable run = new Runnable() {
			
			@Override
			public void run() {
				
			}
		};
	}
	
	public void methodMitException2() throws IllegalArgumentException {
		int x;
		long y;
		double  z;
		short s;
		float f;
		boolean b;
		
		int [] [] multi = new int [4] [6];
		
		try {
			x = 2;
			x++;
			y= 1L;
			y++;
			z= 3.0;
			s = 5;
			f = 4.0f;
			b  = false;
		} catch (RuntimeException e) {
			x = 1;
		} finally {
			x = 3;
		}
	}
	
	public void interfaceCall() {
		Interface1 intf = new Class3();
		intf.testMethod(3);
	}
	
	public void switchMethod(int a) {
		int r = -1;
		switch(a) {
			case 1: r = 1;
			break;
			case 3: r = 5;
			break;
			case 5: r = 7;
			break;
			default: r= 10;
			
		}
	}
	
	public void switchMethod2(int a) {
		int r = -1;
		switch(a) {
			case 1: r = 1;
			break;
			case 3: r = 5;
			break;
			case 100: r = 7;
			break;
			default: r= 10;
			
		}
	}
	
	private class InnerClass {
		
	}
	

}
