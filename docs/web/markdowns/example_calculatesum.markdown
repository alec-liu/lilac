[Raw code](codeexamples/calculatesum.jasm)
	
	:::lilac
	public super class {
	  version 52.0;
	  name ThisClass; 
	  extends Object; 
  
	   //Constants
   
	  const classref ThisClass ThisClass_name;
	  const utf8 ThisClass_name "org/jasm/examples/CalculateSum";
  
	  const classref Object Object_name;
	  const utf8 Object_name "java/lang/Object";
  
	  const classref System System_name;
	  const utf8 System_name "java/lang/System";
  
	  const utf8 out_name "out";
	  const utf8 out_desc "Ljava/io/PrintStream;";
	  const nameandtype System.out_nat out_name,out_desc;
	  const fieldref System.out System,System.out_nat;
  
	  const classref PrintStream PrintStream_name;
	  const utf8 PrintStream_name "java/io/PrintStream";
  
	  const utf8 println_name "println";
	  const utf8 println_desc "(Ljava/lang/Object;)V";
	  const nameandtype PrintStream.println_nat println_name,println_desc;
	  const methodref PrintStream.println PrintStream,PrintStream.println_nat;
  
	  const utf8 init0_name "<init>";
	  const utf8 init0_desc "()V";
	  const methodref Object.init0 Object, Object.init0_nat; 
	  const nameandtype Object.init0_nat init0_name, init0_desc;
  
	  const classref StringBuffer StringBuffer_name;
	  const utf8 StringBuffer_name "java/lang/StringBuffer";
  
	  const methodref StringBuffer.init0 StringBuffer, StringBuffer.init0_nat;
	  const nameandtype StringBuffer.init0_nat init0_name, init0_desc;
  
	  const utf8 append_name "append";
	  const utf8 appendObject_desc "(Ljava/lang/Object;)Ljava/lang/StringBuffer;";
	  const nameandtype StringBuffer.appendObject_nat append_name,appendObject_desc;
	  const methodref StringBuffer.appendObject StringBuffer,StringBuffer.appendObject_nat;
	  const utf8 appendInt_desc "(I)Ljava/lang/StringBuffer;";
	  const nameandtype StringBuffer.appendInt_nat append_name,appendInt_desc;
	  const methodref StringBuffer.appendInt StringBuffer,StringBuffer.appendInt_nat;
  
	  //This has to be declared if you have code
	  const utf8 Code_utf8 "Code";
	
	  const utf8 main_name "main";
	  const utf8 main_desc "([Ljava/lang/String;)V";
  
	  const utf8 result_content "Result: ";
	  const string resultStr result_content;
  
	  const utf8 eol_content "\n";
	  const string eol result_content;
  
	  const int toSum 1000;
  

	  //Methods
	
	  //Constructor
	  public method {
		name init0_name; 
		descriptor init0_desc; 
	
		//Variables
	
		var object this;
	
		//Instructions
	
		aload this;
		invokespecial Object.init0;
		return;
	  }
 
	  //Main Method
	  public static method {
		name main_name;
		descriptor main_desc;
	
		stackmap;
	
		//Variables
	
		var object args; //This is the method parameter
	
		//Instructions
	
		getstatic System.out;
		new StringBuffer;
		dup;
		invokespecial StringBuffer.init0;
		ldc resultStr;
		invokevirtual StringBuffer.appendObject;
	
		bipush 0;
		ldc toSum;
	
		loop:
		dup;
		bipush 0;
		if_icmpeq end;
		dup_x1;
		iadd;
		swap;
		bipush -1;
		iadd;
		goto loop;
	
		end:
		pop;
		invokevirtual StringBuffer.appendInt;
	
		invokevirtual PrintStream.println;
	
		return;
	  }
	}