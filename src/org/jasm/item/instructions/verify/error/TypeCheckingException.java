package org.jasm.item.instructions.verify.error;

import org.jasm.item.instructions.verify.VerifyException;

public class TypeCheckingException extends RuntimeException {
	
	private VerifyException cause;
	
	public TypeCheckingException(VerifyException e) {
		this.cause = e;
	}

	public VerifyException getCause() {
		return cause;
	}
	
	

}
