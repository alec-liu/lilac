package org.jasm.item.instructions;

import org.jasm.bytebuffer.IByteBuffer;
import org.jasm.item.constantpool.InterfaceMethodrefInfo;
import org.jasm.item.constantpool.InvokeDynamicInfo;
import org.jasm.item.descriptor.MethodDescriptor;
import org.jasm.item.descriptor.TypeDescriptor;

public class InvokeDynamicInstruction extends ConstantPoolInstruction {
	

	public InvokeDynamicInstruction(short opCode, InterfaceMethodrefInfo entry) {
		super(opCode, entry);
	}

	@Override
	public int getLength() {
		return super.getLength()+2;
	}

	@Override
	public void read(IByteBuffer source, long offset) {
		super.read(source, offset);
	}

	@Override
	public void write(IByteBuffer target, long offset) {
		super.write(target, offset);
		target.writeUnsignedShort(offset+2, 0);
	}

}
