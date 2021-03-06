grammar JavaAssembler;


//Parser

javatype: primitive_javatype 
		  | class_javatype
		  | array_javatype;

primitive_javatype: BYTE|BOOLEAN|CHAR|DOUBLE|FLOAT|INT|LONG|SHORT;
class_javatype: BinaryIdentifier|Identifier;
array_javatype: (primitive_javatype|class_javatype) (LSQUAREBRACE  RSQUAREBRACE)+;

clazz:
	 classmodifier? CLASS LBRACE 
	 	classmember*
	 RBRACE;

classmember: version SEMI
			 | classname SEMI
			 | superclass SEMI
			 | interfaces SEMI
			 | constpoolentry SEMI
			 | classattribute
			 | method
			 | field
			 ;
			 
			 

version: VERSION FloatingPointLiteral;

classname: NAME Identifier;

superclass: EXTENDS Identifier;

interfaces: IMPLEMENTS labeledIdentifier (COMMA labeledIdentifier)*;

classmodifier: classmodifierlabel (classmodifierlabel)*;

classmodifierlabel: PUBLIC 		# classmodifierPublic
					| FINAL  		# classmodifierFinal
					| SUPER  		# classmodifierSuper
					| INTERFACE  	# classmodifierInterface
					| ABSTRACT   	# classmodifierAbstract
					| SYNTETIC 		# classmodifierSyntetic
					| ANNOTATION    # classmodifierAnnotation
					| ENUM			# classmodifierEnum
					;
					

constpoolentry:  CONST UTF8INFO label StringLiteral #utf8info
				 | CONST CLASSINFO  label Identifier #classinfo
				 | CONST CLASSINFO  BinaryIdentifier (AS label)? #macroclassinfo
				 | CONST CLASSINFO  array_javatype AS label #macroclassarrayinfo
				 | CONST STRING label Identifier #stringinfo
				 | CONST STRING label StringLiteral #macrostringinfo
				 | CONST FIELDREFINFO label Identifier COMMA  Identifier #fieldrefinfo
				 | CONST FIELDREFINFO javatype label FROM (Identifier|BinaryIdentifier) (AS label)? #macrofieldrefinfo
				 | CONST INT label IntegerLiteral  #integerinfo
				 | CONST LONG label IntegerLiteral  #longinfo
				 | CONST FLOAT   label FloatingPointLiteral  #floatinfo
				 | CONST DOUBLE  label FloatingPointLiteral  #doubleinfo
				 | CONST (METHODREFINFO|INTERFACEMETHODREFINFO) method_highlevel_returntype method_highlevel_name LROUNDBRACE method_highlevel_parameters? RROUNDBRACE FROM (Identifier|BinaryIdentifier) (AS label)? #macromethodrefinfo
				 | CONST METHODREFINFO label Identifier COMMA  Identifier #methodrefinfo
				 | CONST DYNREFINFO label Identifier COMMA  Identifier #dynrefinfo
				 | CONST INTERFACEMETHODREFINFO label Identifier COMMA  Identifier #interfacemethodrefinfo
				 | CONST NAMEANDTYPEINFO label Identifier COMMA  Identifier #nameandtypeinfo
				 | CONST METHODTYPE label Identifier #methodtypeinfo
				 | CONST (GETFIELD|GETSTATIC|PUTFIELD|PUTSTATIC|INVOKESPECIAL|INVOKEVIRTUAL|INVOKEINTERFACE|INVOKESTATIC|NEWINVOKESPECIAL) METHODHANDLE label Identifier #methodhandleinfo
				 ;

classattribute : SOURCE FILE Identifier SEMI #classattributeSourceFile
			   | signatureattribute #classattributeSignature
			   | synteticattribute #classAttributeSyntetic
			   | deprecatedattribute #classAttributeDeprecated
			   | annotation #classAnnotation 
			   | typeannotation #classTypeAnnotation 
			   | bootstrapmethod #classBootstrapMethod 
			   | innerclass #classInnerClass
			   | enclosingmethod #classEnclosingMethod
			   | unknownattribute #classUnknownattribute
			   ;
			   
innerclass: innerclass_modifier? INNER CLASS LBRACE 
	 			innerclassmember*
	 		RBRACE;

innerclassmember: innerclass_inner SEMI
				  | innerclass_outer SEMI
				  | innerclass_name SEMI
				  ;

innerclass_inner: INNER Identifier;
innerclass_outer: OUTER Identifier;
innerclass_name: NAME Identifier;
innerclass_modifier: innerclassmodifierlabel (innerclassmodifierlabel)*;
innerclassmodifierlabel: PUBLIC #innerclassmodifierPublic
						|PRIVATE #innerclassmodifierPrivate
						|PROTECTED #innerclassmodifierProtected
						|STATIC #innerclassmodifierStatic
						|FINAL #innerclassmodifierFinal
						|INTERFACE #innerclassmodifierInterface
						|ABSTRACT #innerclassmodifierAbstract
						|SYNTETIC #innerclassmodifierSyntetic
						|ANNOTATION #innerclassmodifierAnnotation
						|ENUM #innerclassmodifierEnum
						; 

enclosingmethod: ENCLOSING METHOD Identifier (COMMA Identifier)? SEMI;
bootstrapmethod: BOOTSTRAP METHOD Identifier Identifier (COMMA Identifier)* SEMI;

method: method_lowlevel | method_highlevel;

method_lowlevel  : methodmodifier? METHOD  LBRACE
			 methodmember*
		 RBRACE;

method_highlevel: methodmodifier? method_highlevel_returntype method_highlevel_name LROUNDBRACE method_highlevel_parameters? RROUNDBRACE ((LBRACE
					methodmember*
				  RBRACE)|(SEMI));

methodmember: methodname SEMI
			  | methoddescriptor SEMI
			  | methodattribute
			  | methodvar
			  | methodinstruction
			  | methodexceptionhandler
			  | methodlinenumbertable
			  | methodvariabletable
			  | methodvariabletypetable
			  | methodmaxstack
			  | methodmaxlocals
			  ;
				  
methodname: NAME Identifier;
methoddescriptor: DESCRIPTOR Identifier;

methodmodifier: methodmodifierlabel (methodmodifierlabel)*;

method_highlevel_returntype: VOID|javatype;
method_highlevel_name: INIT|CLINIT|Identifier;

method_highlevel_parameters: method_highlevel_parameter (COMMA method_highlevel_parameter)*;

method_highlevel_parameter: javatype Identifier;
				  
methodmodifierlabel:  PUBLIC 		# methodmodifierPublic
					| PRIVATE  		# methodmodifierPrivate
					| PROTECTED  	# methodmodifierProtected
					| STATIC 		# methodmodifierStatic
					| FINAL         # methodmodifierFinal
					| SYNCHRONIZED	# methodmodifierSynchronized
					| BRIDGE	    # methodmodifierBridge
					| VARARGS	    # methodmodifierVarargs
					| NATIVE	    # methodmodifierNative
					| ABSTRACT   	# methodmodifierAbstract
					| STRICT 	    # methodmodifierStrict
					| SYNTETIC 	    # methodmodifierSyntetic
					;

methodattribute:   exceptionsattribute #methodAttributeExceptions
				 | signatureattribute #methodAttributeSignature
				 | synteticattribute #methodAttributeSyntetic
				 | deprecatedattribute #methodAttributeDeprecated
				 | annotation #methodAnnotation
				 | parameterannotation #methodParameterAnnotation 
				 | typeannotation #methodTypeAnnotation 
				 | annotationdefault #methodAnnotationDefault
				 | unknownattribute #methodUnknownattribute
				 | stackmapattribute #methodStackmapattribute
				 ;

exceptionsattribute: THROWS labeledIdentifier (COMMA labeledIdentifier)* SEMI;

methodvar: methodvarimplicit #methodvar_implicit
		   | methodvarrelative #methodvar_relative
		   | methodvarabsolute #methodvar_absolute
		   ;
		   
methodvartype: DOUBLE|FLOAT|INT|LONG|OBJECT|RETURNADRESS;



methodvarimplicit: VAR methodvartype Identifier SEMI;
methodvarrelative: VAR methodvartype Identifier AT Identifier ( Plus? IntegerLiteral)? SEMI;
methodvarabsolute: VAR methodvartype Identifier AT IntegerLiteral SEMI;

methodinstruction: (label COLON)? (instruction|macrocall) SEMI;

methodexceptionhandler: (label COLON)? TRY Identifier Pointer Identifier CATCH identifierOrAll GO TO Identifier SEMI;

methodlinenumbertable: LINE NUMBERS LBRACE
					   	  linenumber*
					   RBRACE;

linenumber: LINE Identifier COMMA IntegerLiteral SEMI;

methodvariabletable: DEBUG VARS LBRACE
					   	  debugvar*
					  RBRACE;

debugvar: VAR Identifier COMMA Identifier (Pointer Identifier)? COMMA Identifier COMMA Identifier  SEMI;


methodvariabletypetable: DEBUG VAR TYPES LBRACE
					   	 	 debugvartype*
					  	 RBRACE;

debugvartype: VAR Identifier COMMA Identifier (Pointer Identifier)? COMMA Identifier COMMA Identifier  SEMI;

instruction: argumentlessop_keyword #argumentlessop
			 | constantpoolop_keyword Identifier #constantpoolop
			 | WIDE? LDC Identifier #ldcop
			 | wideOrNormal? localvarop_keyword Identifier #localvarop
			 | retop_keyword Identifier #retop
			 | pushop_keyword IntegerLiteral #pushop
			 | WIDE? iincop_keyword Identifier COMMA IntegerLiteral #iincop
			 | newarrayop_keyword arrayType #newarrayop
			 | multinewarrayop_keyword Identifier COMMA IntegerLiteral #multinewarrayop 
			 | switchop_keyword switchMember (COMMA switchMember)* #switchop 
			 | branchop_keyword Identifier #branchop
			 ;

macrocall: (Identifier|BuiltInMacroIdentifier) LROUNDBRACE macroarguments? RROUNDBRACE;
macroarguments: macroargument (COMMA macroargument)*;
macroargument: macroargumentcast? IntegerLiteral #intmacroargument
			   |macroargumentcast? FloatingPointLiteral #floatmacroargument
			   |macroargumentcast? StringLiteral #stringmacroargument
			   |macroargumentcast? NULL #nullmacroargument
			   |macroargumentcast? Identifier #idmacroargument
			   |macroargumentcast? macrocall #macrocallmacroargument
			   ;
macroargumentcast: LROUNDBRACE javatype RROUNDBRACE;			   

methodmaxstack: MAXSTACK IntegerLiteral SEMI;
methodmaxlocals: MAXLOCALS IntegerLiteral SEMI;

field: field_lowlevel | field_highlevel;

field_highlevel: fieldmodifier? javatype Identifier  ((LBRACE
					fieldmember*
				  RBRACE)|(SEMI));

field_lowlevel  : fieldmodifier? FIELD  LBRACE
					fieldmember*
				  RBRACE;

fieldmember: fieldname SEMI
			  | fielddescriptor SEMI
			  | fieldattribute
			  ;
				  
fieldname: NAME Identifier;
fielddescriptor: DESCRIPTOR Identifier;

fieldmodifier: fieldmodifierlabel (fieldmodifierlabel)*;
				  

fieldmodifierlabel:   PUBLIC 		# fieldmodifierPublic
					| PRIVATE  		# fieldmodifierPrivate
					| PROTECTED  	# fieldmodifierProtected
					| STATIC 		# fieldmodifierStatic
					| FINAL         # fieldmodifierFinal
					| VOLATILE  	# fieldmodifierVolatile
					| TRANSIENT	    # fieldmodifierTransient
					| SYNTETIC 	    # fieldmodifierSyntetic
					| ENUM	 	    # fieldmodifierEnum
					;

fieldattribute : CONSTANT VALUE Identifier SEMI #fieldattributeConstantValue
				  | signatureattribute #fieldAttributeSignature
				  | synteticattribute #fieldAttributeSyntetic
				  | deprecatedattribute #fieldAttributeDeprecated
				  | annotation #fieldAnnotation
				  | typeannotation #fieldTypeAnnotation
				  | unknownattribute #fieldUnknownattribute 
				 ;


signatureattribute: SIGNATURE Identifier SEMI;
synteticattribute: SYNTETIC SEMI;
deprecatedattribute: DEPRECATED SEMI;


annotation: INVISIBLE? annotationdeclaration;

annotationdeclaration: ANNOTATION  LBRACE
						 (annotationmember)*
					   RBRACE;

annotationmember: annotationtype|annotationelement;
					   
parameterannotation: INVISIBLE? PARAMETER parameterannotationdeclaration;

parameterannotationdeclaration: ANNOTATION  LBRACE
						 			(parameterannotationmember)*
					   			RBRACE;
					   			
parameterannotationmember: annotationtype|annotationparameterindex|annotationelement;
					   			
typeannotation: INVISIBLE? TYPE typeannotationdeclaration;

typeannotationdeclaration:ANNOTATION  LBRACE
					 			(typeannotationmember)*
					   	  RBRACE;

typeannotationmember: annotationtype|annotationtarget|annotationtargetpath|annotationelement;

annotationtarget: TARGETS RETURN TYPE SEMI #emptyTargetReturnType
				  |TARGETS RECEIVER TYPE SEMI #emptyTargetReceiverType
				  |TARGETS FIELD TYPE SEMI #emptyTargetFieldType
				  |TARGETS TYPE PARAMETER IntegerLiteral SEMI #parameterTypeTargetType
				  |TARGETS TYPE PARAMETER BOUND IntegerLiteral COMMA IntegerLiteral SEMI #parameterTypeBoundTargetType
				  |TARGETS SUPERTYPE Identifier? SEMI #supertypeTargetType
				  |TARGETS THROWS TYPE Identifier SEMI #throwstypeTargetType
				  |TARGETS PARAMETER TYPE IntegerLiteral SEMI #formalparametertypeTargetType
				  |TARGETS NEW TYPE Identifier SEMI #newtypeTargetType
				  |TARGETS INSTANCEOF TYPE Identifier SEMI #instanceoftypeTargetType
				  |TARGETS METHOD REFERENCE TYPE Identifier SEMI #methodreferencetypeTargetType
				  |TARGETS CONSTRUCTOR REFERENCE TYPE Identifier SEMI #constructorreferencetypeTargetType
				  |TARGETS CAST TYPE Identifier COMMA IntegerLiteral SEMI #casttypeTargetType
				  |TARGETS CONSTRUCTOR TYPE ARGUMENT Identifier COMMA IntegerLiteral SEMI #constructortypeargumentTargetType
				  |TARGETS CONSTRUCTOR REFERENCE TYPE ARGUMENT Identifier COMMA IntegerLiteral SEMI #constructorreferencetypeargumentTargetType
				  |TARGETS METHOD TYPE ARGUMENT Identifier COMMA IntegerLiteral SEMI #methodtypeargumentTargetType
				  |TARGETS METHOD REFERENCE TYPE ARGUMENT Identifier COMMA IntegerLiteral SEMI #methodreferencetypeargumentTargetType
				  |TARGETS CATCH TYPE  Identifier SEMI #catchtypeTargetType
				  |TARGETS (RESOURCE)? VAR TYPES LBRACE (localvartypemember)* RBRACE #localvartypeTargetType
				  ;

localvartypemember: TARGETED VAR localvartypemember_vararg COMMA Identifier (Pointer Identifier)? SEMI;
localvartypemember_vararg: IntegerLiteral|Identifier;

			 

annotationtargetpath: TARGET PATH annotationtargetpath_arg (COMMA annotationtargetpath_arg)* SEMI;
annotationtargetpath_arg: ARRAY #targetPathArray
						  |NESTED #targetPathNested
						  |TYPE ARGUMENT BOUND #targetPathTypeArgumentBound
						  |TYPE ARGUMENT '(' IntegerLiteral ')' #targetPathTypeArgument;

					   
annotationdefault: ANNOTATION DEFAULT LBRACE
				   	 annotationelementvalue*
				   RBRACE;
					   
annotationtype: TYPE Identifier SEMI;
annotationparameterindex: INDEX IntegerLiteral SEMI;

annotationelement: ELEMENT LBRACE
					 (annotationelementmember)*
				   RBRACE;

annotationelementmember: annotationelementname|annotationelementvalue;

annotationelementname: NAME Identifier SEMI;

annotationelementvalue: simpleannotationelementvalue|enumannotationelementvalue|arrayannotationelementvalue|annotationdeclaration;

simpleannotationelementvalue: (BYTE|CHAR|FLOAT|DOUBLE|INT|LONG|SHORT|STRING|BOOLEAN|CLASS) VALUE Identifier SEMI;
enumannotationelementvalue: ENUM VALUE Identifier COMMA Identifier SEMI;
arrayannotationelementvalue: ARRAY VALUE LBRACE
								annotationelementvalue*
							 RBRACE;


label: Identifier;
labeledIdentifier: (label COLON)? Identifier;


wideOrNormal : WIDE|NORMAL;

arrayType: BOOLEAN|BYTE|CHAR|DOUBLE|FLOAT|INT|LONG|SHORT;

switchSource: DEFAULT|IntegerLiteral;
switchMember: switchSource Pointer Identifier;

identifierOrAll: ALL|Identifier;

unknownattribute: UNKNOWN CODE? ATTRIBUTE Identifier COMMA Base64Literal SEMI;

stackmapattribute: STACKMAP LBRACE stackmapframe* RBRACE #extendedStackmapAttribute
				   | STACKMAP SEMI #simpleStackmapAttribute
				   ;

stackmapframe: APPEND Identifier COMMA stackmapvarinfos SEMI #appendStackmapFrame
		       | CHOP Identifier COMMA IntegerLiteral SEMI #chopStackmapFrame
		       | FULL Identifier COMMA localstackmapvarinfos COMMA stackitemstackmapvarinfos SEMI #fullStackmapFrame
		       | SAME Identifier SEMI #sameStackmapFrame
		       | SAME EXTENDED Identifier SEMI #sameExtendedStackmapFrame
		       | SAME LOCALS Identifier COMMA stackmapvarinfo SEMI #sameLocalsStackmapFrame
		       | SAME LOCALS EXTENDED Identifier COMMA stackmapvarinfo SEMI #sameLocalsExtendedStackmapFrame
		       ;
		       
stackmapvarinfos: LBRACE RBRACE #emptyStackmapvarinfos
				  |LBRACE stackmapvarinfo (COMMA stackmapvarinfo)* RBRACE #notemptyStackmapvarinfos
				  ;
					
				  

localstackmapvarinfos: stackmapvarinfos;
stackitemstackmapvarinfos: stackmapvarinfos;

stackmapvarinfo: TOP #topStackmapvarinfo
				 | FLOAT #floatStackmapvarinfo
				 | DOUBLE #doubleStackmapvarinfo
				 | INT #intStackmapvarinfo
				 | LONG #longStackmapvarinfo
				 | NULL #nullStackmapvarinfo
				 | UNINITIALIZED Identifier #uninitializedStackmapvarinfo
				 | UNINITIALIZEDTHIS #uninitializedThisStackmapvarinfo
				 | OBJECT Identifier #objectStackmapvarinfo
				 ;




//Instruction Rules

argumentlessop_keyword: AALOAD|AASTORE|ACONST_NULL|ARETURN|ARRAYLENGTH|ATHROW|BALOAD|BASTORE|CALOAD|CASTORE|D2F|D2I|D2L|DADD|DALOAD|DASTORE|DCMPG|DCMPL|DCONST_0|DCONST_1|DDIV|DMUL|DNEG|DREM|DRETURN|DSUB|DUP|DUP_X1|DUP_X2|DUP2|DUP2_X1|DUP2_X2|F2D|F2I|F2L|FADD|FALOAD|FASTORE|FCMPG|FCMPL|FCONST_0|FCONST_1|FCONST_2|FDIV|FMUL|FNEG|FREM|FRETURN|FSUB|I2B|I2C|I2D|I2F|I2L|I2S|IADD|IALOAD|IAND|IASTORE|ICONST_M1|ICONST_0|ICONST_1|ICONST_2|ICONST_3|ICONST_4|ICONST_5|IDIV|IMUL|INEG|IOR|IREM|IRETURN|ISHL|ISHR|ISUB|IUSHR|IXOR|L2D|L2F|L2I|LADD|LALOAD|LAND|LASTORE|LCMP|LCONST_0|LCONST_1|LDIV|LMUL|LNEG|LOR|LREM|LRETURN|LSHL|LSHR|LSUB|LUSHR|LXOR|MONITORENTER|MONITOREXIT|NOP|POP|POP2|RETURN|SALOAD|SASTORE|SWAP;
constantpoolop_keyword: INVOKEINTERFACE|INVOKEDYNAMIC|ANEWARRAY|CHECKCAST|GETFIELD|GETSTATIC|INSTANCEOF|INVOKESPECIAL|INVOKESTATIC|INVOKEVIRTUAL|LDC2_W|LDC2|NEW|PUTFIELD|PUTSTATIC;
localvarop_keyword: ALOAD|ASTORE|DLOAD|DSTORE|FLOAD|FSTORE|ILOAD|ISTORE|LLOAD|LSTORE;
retop_keyword: RET;
branchop_keyword: GOTO|GOTO_W|IF_ACMPEQ|IF_ACMPNE|IF_ICMPEQ|IF_ICMPGE|IF_ICMPGT|IF_ICMPLE|IF_ICMPLT|IF_ICMPNE|IFEQ|IFGE|IFGT|IFLE|IFLT|IFNE|IFNONNULL|IFNULL|JSR|JSR_W;
pushop_keyword: BIPUSH|SIPUSH; 
iincop_keyword: IINC;
newarrayop_keyword: NEWARRAY;
multinewarrayop_keyword: MULTIANEWARRAY;
switchop_keyword: LOOKUPSWITCH|TABLESWITCH;

//Lexer

// Keywords
//startKeywords

CLASS         :  'class';
CONST         :  'const';
CONSTANT      :  'constant';
VERSION       :  'version';
NAME          :  'name';
EXTENDS       :  'extends';
IMPLEMENTS    :  'implements';
PUBLIC        :  'public';
FINAL         :  'final';
SUPER         :  'super';
INTERFACE     :  'interface';
ABSTRACT      :  'abstract';
SYNTETIC      :  'synthetic';
ANNOTATION    :  'annotation';
ENUM          :  'enum';
ATTRIBUTE     :  'attribute';
SOURCE        :  'source';
FILE          :  'file';
METHOD        :  'method';
FIELD         :  'field';
DESCRIPTOR    :  'descriptor';
PRIVATE       :  'private';
PROTECTED     :  'protected';
STATIC        :  'static';
SYNCHRONIZED  :  'synchronized';
VARARGS       :  'varargs';
NATIVE        :  'native';
STRICT        :  'strict';
VOLATILE      :  'volatile';
TRANSIENT     :  'transient';
BRIDGE        :  'bridge';
VALUE         :  'value';
THROWS        :  'throws';
SIGNATURE     :  'signature';
DEPRECATED    :  'deprecated';
INVISIBLE     :  'invisible';
TYPE          :  'type';
TYPES         :  'types';
ELEMENT       :  'element';
ARRAY         :  'array';
INDEX         :  'index';
PARAMETER     :  'parameter';
INNER         :  'inner';
OUTER         :  'outer';
ENCLOSING     :  'enclosing';
AT            :  'at';
VAR           :  'var';
VARS          :  'vars';
NORMAL        :  'normal';
ALL        	  :  'all';
GO        	  :  'go';
TO       	  :  'to';
TRY        	  :  'try';
CATCH      	  :  'catch';
DEFAULT       :  'default';
UNKNOWN       :  'unknown';
CODE          :  'code';
STACKMAP      :  'stackmap';
LINE          :  'line';
NUMBERS       :  'numbers';
DEBUG         :  'debug';
MAXSTACK      :  'maxstack';
MAXLOCALS     :  'maxlocals';
TARGET        :  'target';
TARGETS       :  'targets';
TARGETED      :  'targeted';
RECEIVER      :  'receiver';
NESTED        :  'nested';
ARGUMENT      :  'argument';
BOUND         :  'bound';
PATH          :  'path';
SUPERTYPE     :  'supertype';
FORMAL        :  'formal';
REFERENCE     :  'reference';
CONSTRUCTOR   :  'constructor';
CAST          :  'cast';
RESOURCE      :  'resource';
NEWINVOKESPECIAL : 'newinvokespecial';
BOOTSTRAP     : 'bootstrap';
APPEND        : 'append';
SAME          : 'same';
LOCALS        : 'locals';
EXTENDED      : 'extended';
FULL          : 'full';
CHOP          : 'chop';
INIT          : '<init>';
CLINIT          : '<clinit>';
AS          : 'as';
FROM          : 'from';


//stopKeywords

//Data types
//startKeywords

CLASSINFO     :  'classref';
UTF8INFO      :  'utf8';
FIELDREFINFO  :  'fieldref';
METHODREFINFO :  'methodref';
DYNREFINFO    :  'dynref';
INTERFACEMETHODREFINFO : 'intfmethodref';
NAMEANDTYPEINFO :  'nameandtype';
BYTE          :  'byte';
CHAR          :  'char';
DOUBLE        :  'double';
FLOAT         :  'float';
INT           :  'int';
LONG          :  'long';
SHORT         :  'short';
STRING        :  'string';
BOOLEAN       :  'boolean';
OBJECT        :  'object';
RETURNADRESS  :  'returnadress';
TOP           : 'top';
UNINITIALIZED: 'uninitialized';
UNINITIALIZEDTHIS: 'uninitializedthis';
METHODHANDLE  :  'methodhandle';
METHODTYPE    :  'methodtype';
NULL          : 'null';
VOID          : 'void';


//stopKeywords

//Instructions (some also used as keywords)
//startKeywords

AALOAD: 'aaload';
AASTORE: 'aastore';
ACONST_NULL: 'aconst_null';
ALOAD: 'aload';
ANEWARRAY: 'anewarray';
ARETURN: 'areturn';
ARRAYLENGTH: 'arraylength';
ASTORE: 'astore';
ATHROW: 'athrow';
BALOAD: 'baload';
BASTORE: 'bastore';
BIPUSH: 'bipush';
CALOAD: 'caload';
CASTORE: 'castore';
CHECKCAST: 'checkcast';
D2F: 'd2f';
D2I: 'd2i';
D2L: 'd2l';
DADD: 'dadd';
DALOAD: 'daload';
DASTORE: 'dastore';
DCMPG: 'dcmpg';
DCMPL: 'dcmpl';
DCONST_0: 'dconst_0';
DCONST_1: 'dconst_1';
DDIV: 'ddiv';
DLOAD: 'dload';
DMUL: 'dmul';
DNEG: 'dneg';
DREM: 'drem';
DRETURN: 'dreturn';
DSTORE: 'dstore';
DSUB: 'dsub';
DUP: 'dup';
DUP2: 'dup2';
DUP2_X1: 'dup2_x1';
DUP2_X2: 'dup2_x2';
DUP_X1: 'dup_x1';
DUP_X2: 'dup_x2';
F2D: 'f2d';
F2I: 'f2i';
F2L: 'f2l';
FADD: 'fadd';
FALOAD: 'faload';
FASTORE: 'fastore';
FCMPG: 'fcmpg';
FCMPL: 'fcmpl';
FCONST_0: 'fconst_0';
FCONST_1: 'fconst_1';
FCONST_2: 'fconst_2';
FDIV: 'fdiv';
FLOAD: 'fload';
FMUL: 'fmul';
FNEG: 'fneg';
FREM: 'frem';
FRETURN: 'freturn';
FSTORE: 'fstore';
FSUB: 'fsub';
GETFIELD: 'getfield';
GETSTATIC: 'getstatic';
GOTO: 'goto';
GOTO_W: 'goto_w';
I2B: 'i2b';
I2C: 'i2c';
I2D: 'i2d';
I2F: 'i2f';
I2L: 'i2l';
I2S: 'i2s';
IADD: 'iadd';
IALOAD: 'iaload';
IAND: 'iand';
IASTORE: 'iastore';
ICONST_0: 'iconst_0';
ICONST_1: 'iconst_1';
ICONST_2: 'iconst_2';
ICONST_3: 'iconst_3';
ICONST_4: 'iconst_4';
ICONST_5: 'iconst_5';
ICONST_M1: 'iconst_m1';
IDIV: 'idiv';
IF_ACMPEQ: 'if_acmpeq';
IF_ACMPNE: 'if_acmpne';
IF_ICMPEQ: 'if_icmpeq';
IF_ICMPGE: 'if_icmpge';
IF_ICMPGT: 'if_icmpgt';
IF_ICMPLE: 'if_icmple';
IF_ICMPLT: 'if_icmplt';
IF_ICMPNE: 'if_icmpne';
IFEQ: 'ifeq';
IFGE: 'ifge';
IFGT: 'ifgt';
IFLE: 'ifle';
IFLT: 'iflt';
IFNE: 'ifne';
IFNONNULL: 'ifnonnull';
IFNULL: 'ifnull';
IINC: 'iinc';
ILOAD: 'iload';
IMUL: 'imul';
INEG: 'ineg';
INSTANCEOF: 'instanceof';
INVOKEDYNAMIC: 'invokedynamic';
INVOKEINTERFACE: 'invokeinterface';
INVOKESPECIAL: 'invokespecial';
INVOKESTATIC: 'invokestatic';
INVOKEVIRTUAL: 'invokevirtual';
IOR: 'ior';
IREM: 'irem';
IRETURN: 'ireturn';
ISHL: 'ishl';
ISHR: 'ishr';
ISTORE: 'istore';
ISUB: 'isub';
IUSHR: 'iushr';
IXOR: 'ixor';
JSR: 'jsr';
JSR_W: 'jsr_w';
L2D: 'l2d';
L2F: 'l2f';
L2I: 'l2i';
LADD: 'ladd';
LALOAD: 'laload';
LAND: 'land';
LASTORE: 'lastore';
LCMP: 'lcmp';
LCONST_0: 'lconst_0';
LCONST_1: 'lconst_1';
LDC: 'ldc';
LDC2_W: 'ldc2_w';
LDC2: 'ldc2';
LDIV: 'ldiv';
LLOAD: 'lload';
LMUL: 'lmul';
LNEG: 'lneg';
LOOKUPSWITCH: 'lookupswitch';
LOR: 'lor';
LREM: 'lrem';
LRETURN: 'lreturn';
LSHL: 'lshl';
LSHR: 'lshr';
LSTORE: 'lstore';
LSUB: 'lsub';
LUSHR: 'lushr';
LXOR: 'lxor';
MONITORENTER: 'monitorenter';
MONITOREXIT: 'monitorexit';
MULTIANEWARRAY: 'multianewarray';
NEW: 'new';
NEWARRAY: 'newarray';
NOP: 'nop';
POP: 'pop';
POP2: 'pop2';
PUTFIELD: 'putfield';
PUTSTATIC: 'putstatic';
RET: 'ret';
RETURN: 'return';
SALOAD: 'saload';
SASTORE: 'sastore';
SIPUSH: 'sipush';
SWAP: 'swap';
TABLESWITCH: 'tableswitch';
WIDE: 'wide';

//stopKeywords

Plus            :  '+';
Pointer   : '->';

// Integer Literals

IntegerLiteral
    :   Sign? DecimalIntegerLiteral
    |   Sign? HexIntegerLiteral
    |   Sign? OctalIntegerLiteral
    |   Sign? BinaryIntegerLiteral
    ;

fragment
DecimalIntegerLiteral
    :   DecimalNumeral
    ;

fragment
HexIntegerLiteral
    :   HexNumeral
    ;

fragment
OctalIntegerLiteral
    :   OctalNumeral
    ;

fragment
BinaryIntegerLiteral
    :   BinaryNumeral
    ;


fragment
DecimalNumeral
    :   '0'
    |   NonZeroDigit Digit*
    ;


fragment
Digit
    :   '0'
    |   NonZeroDigit
    ;

fragment
NonZeroDigit
    :   [1-9]
    ;

fragment
HexNumeral
    :   '0' [xX] HexDigits
    ;

fragment
HexDigits
    :   HexDigit+
    ;

fragment
HexDigit
    :   [0-9a-fA-F]
    ;

fragment
OctalNumeral
    :   '0' OctalDigits
    ;

fragment
OctalDigits
    :   OctalDigit+
    ;

fragment
OctalDigit
    :   [0-7]
    ;



fragment
BinaryNumeral
    :   '0' [bB] BinaryDigits
    ;

fragment
BinaryDigits
    :   BinaryDigit+
    ;

fragment
BinaryDigit
    :   [01]
    ;


// Floating-Point Literal

FloatingPointLiteral
	: Sign? HexFloatingPointLiteral  
	| Sign? DecimalFloatingPointLiteral
    |   'NaN'
    |   Sign? 'Infinity'
    ;

fragment
DecimalFloatingPointLiteral
    :   DecimalNumeral '.' Digit+ ExponentPart?;

fragment
HexFloatingPointLiteral
    :   BinaryDigit '.' HexDigit+ HexExponentPart;



fragment
ExponentPart
    :   ExponentIndicator Sign? DecimalNumeral
    ;
    
fragment
HexExponentPart
    :   BinaryExponentIndicator Sign? HexDigits
    ;

fragment
ExponentIndicator
    :   [eE]
    ;

fragment
BinaryExponentIndicator
    :   [pP]
    ;


fragment
Sign
    :   [+-]
    ;


 

// String Literals

StringLiteral
    :   '"' StringCharacters? '"'
    ;

fragment
StringCharacters
    :   StringCharacter+
    ;

fragment
StringCharacter
    :   ~["\\]
    |   EscapeSequence
    ;

// Escape Sequences for Character and String Literals

fragment
EscapeSequence
    :   '\\' [btnfr"'\\]
    |   OctalEscape
    |   UnicodeEscape
    ;

fragment
OctalEscape
    :   '\\' OctalDigit
    |   '\\' OctalDigit OctalDigit
    |   '\\' ZeroToThree OctalDigit OctalDigit
    ;

fragment
UnicodeEscape
    :   '\\' 'u' HexDigit HexDigit HexDigit HexDigit
    ;

fragment
ZeroToThree
    :   [0-3]
    ;

// Separators
LBRACE          : '{';
RBRACE          : '}';
SEMI            : ';';
COMMA           : ',';
COLON           : ':';
LROUNDBRACE     : '(';
RROUNDBRACE     : ')';
LSQUAREBRACE     : '[';
RSQUAREBRACE     : ']';

// Identifiers

Identifier: QuotedIdentifier|UnquotedIdentifier;
QuotedIdentifier: '\'' SimpleIdentifier '\'';
UnquotedIdentifier: SimpleIdentifier ('.' SimpleIdentifier)*;

BuiltInMacroIdentifier: '.' SimpleIdentifier;

BinaryIdentifier:  SimpleIdentifier? ('/' SimpleIdentifier) ('/' SimpleIdentifier)*;

fragment SimpleIdentifier
    :   JavaLetter JavaLetterOrDigit*
    ;

ConstructorIdentifier: '<init>';

fragment
JavaLetter
    :   [a-zA-Z$_] // these are the "java letters" below 0xFF
    |   // covers all characters above 0xFF which are not a surrogate
        ~[\u0000-\u00FF\uD800-\uDBFF]
        {Character.isJavaIdentifierStart(_input.LA(-1))}?
    |   // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
        [\uD800-\uDBFF] [\uDC00-\uDFFF]
        {Character.isJavaIdentifierStart(Character.toCodePoint((char)_input.LA(-2), (char)_input.LA(-1)))}?
    ;

fragment
JavaLetterOrDigit
    :   [a-zA-Z0-9$_] // these are the "java letters or digits" below 0xFF
    |   // covers all characters above 0xFF which are not a surrogate
        ~[\u0000-\u00FF\uD800-\uDBFF]
        {Character.isJavaIdentifierPart(_input.LA(-1))}?
    |   // covers UTF-16 surrogate pairs encodings for U+10000 to U+10FFFF
        [\uD800-\uDBFF] [\uDC00-\uDFFF]
        {Character.isJavaIdentifierPart(Character.toCodePoint((char)_input.LA(-2), (char)_input.LA(-1)))}?
    ;

//Descriptors
fragment TypeDescriptor : BaseTypeDescriptor | ObjectTypeDescriptor | ArrayTypeDescriptor;
fragment BaseTypeDescriptor: 'B' | 'C' | 'D' | 'F' | 'I' | 'J' | 'S' | 'Z';
fragment InternalClassName: SimpleIdentifier ('/' SimpleIdentifier)*;
fragment ObjectTypeDescriptor: 'L' InternalClassName ';';
fragment ArrayTypeDescriptor: '[' TypeDescriptor;

fragment MethodDescriptor: '(' TypeDescriptor? ')' ReturnDescriptor;
fragment ReturnDescriptor: TypeDescriptor | 'V';


//Base64

Base64Literal: '[' [A-Za-z0-9+/=]+ ']';

//
// Whitespace and comments
//

WS  :  [ \t\r\n\u000C]+ -> skip
    ;

COMMENT
    :   '/*' .*? '*/' -> skip
    ;

LINE_COMMENT
    :   '//' ~[\r\n]* -> skip
    ;


