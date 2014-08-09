package org.jasm.item.instructions;

import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.jasm.bytebuffer.IByteBuffer;
import org.jasm.bytebuffer.print.IPrintable;
import org.jasm.item.AbstractByteCodeItem;
import org.jasm.item.IBytecodeItem;
import org.jasm.item.IContainerBytecodeItem;
import org.slf4j.Logger;
import org.slf4j.LoggerFactory;

public class Instructions extends AbstractByteCodeItem implements IContainerBytecodeItem<AbstractInstruction>, IPrintable {
	
	
	private Logger log = LoggerFactory.getLogger(this.getClass());
	
	private Map<Integer, AbstractInstruction> offsets = new HashMap<>();
	
	private List<AbstractInstruction> items = new ArrayList<>();
	
	@Override
	public String getPrintName() {
		return "instructions";
	}
	
	

	private AbstractInstruction createEmptyItem(IByteBuffer source,
			long offset) {
		short opCode = source.readUnsignedByte(offset);
		
		if (OpCodes.isArgumentLessInstruction(opCode)) {
			return new ArgumentLessInstruction(opCode);
		} else if (OpCodes.isLocalVariableInstruction(opCode)) {
			return new LocalVariableInstruction(opCode, (short)-1);
		} else if (OpCodes.isConstantPoolInstruction(opCode)) {
			return new ConstantPoolInstruction(opCode, null);
		} else if (OpCodes.isBranchInstruction(opCode)) {
			return new BranchInstruction(opCode, null);
		} else if (OpCodes.ldc == opCode) {
			return new LdcInstruction(null);
		} else {
			throw new RuntimeException("Unknown op code: "+Integer.toHexString(opCode)+" at offset "+offset);
		}
		
		
	}

	
	private void setOffsets() {
		for (int i=0;i<items.size(); i++) {
			AbstractInstruction instruction = items.get(i);
			if (i==0) {
				instruction.setOffsetInCode(0);
			} else {
				AbstractInstruction previousInstruction = items.get(i-1);
				instruction.setOffsetInCode(previousInstruction.getOffsetInCode()+previousInstruction.getLength());
			}
			offsets.put(instruction.getOffsetInCode(), instruction);
		}
	}



	public void add(AbstractInstruction item) {
		items.add(item);
		setOffsets();
	}



	public void add(int index, AbstractInstruction item) {
		items.add(index, item);
		setOffsets();
	}


	public void remove(AbstractInstruction item) {
		items.remove(item);
		setOffsets();
	}
	
	public AbstractInstruction getInstructionAtOffset(int offset) {
		if (!offsets.containsKey(offset)) {
			throw new IllegalArgumentException("Illegal Offset: "+offset);
		}
		return offsets.get(offset);
	}



	@Override
	public void read(IByteBuffer source, long offset) {
		long currentOffset = offset;
		long codeLength = source.readUnsignedInt(offset);
		if (codeLength > Integer.MAX_VALUE) {
			throw new RuntimeException("Super long methods not supported!");
		}
		if (log.isDebugEnabled()) {
			log.debug("Reading instructions,offset="+currentOffset+" codeLength = "+codeLength);
		}
		currentOffset+=4;
		while (currentOffset<(offset+codeLength+4)) {
			AbstractInstruction instr = createEmptyItem(source, currentOffset);
			
			instr.setParent(this);
			instr.read(source, currentOffset+1);
			if (log.isDebugEnabled()) {
				log.debug("Read instruction "+instr.getPrintName()+" at offset = "+currentOffset+", length="+instr.getLength());
			}
			items.add(instr);
			currentOffset+=instr.getLength();
		}
		if (currentOffset!=(offset+codeLength+4)) {
			throw new IllegalStateException("last instruction out of code bound: "+currentOffset+"!="+(offset+codeLength+4));
		}
		
	}



	@Override
	public void write(IByteBuffer target, long offset) {
		long currentOffset = offset;
		long codeLength = getLength()-4;
		if (codeLength > Integer.MAX_VALUE) {
			throw new RuntimeException("Super long methods not supported!");
		}
		if (log.isDebugEnabled()) {
			log.debug("Writing instructions,offset="+currentOffset+", codeLength = "+codeLength);
		}
		target.writeUnsignedInt(currentOffset, codeLength);
		currentOffset+=4;
		for (AbstractInstruction instr: items) {
			target.writeUnsignedByte(currentOffset, instr.getOpCode());
			instr.write(target, currentOffset+1);
			if (log.isDebugEnabled()) {
				log.debug("Written instruction "+instr.getPrintName()+" at offset = "+currentOffset+", length="+instr.getLength());
			}
			currentOffset+=instr.getLength();
		}
		if (currentOffset!=(offset+codeLength+4)) {
			throw new IllegalStateException("last instruction out of code bound: "+currentOffset+"!="+(offset+codeLength+4));
		}
		
	}



	@Override
	public int getLength() {
		int result = 4;
		for (IBytecodeItem item: items) {
			if (item != null) {
				result+=item.getLength();
			}
		}
		return result;
	}



	@Override
	public boolean isStructure() {
		return true;
	}



	@Override
	public List<IPrintable> getStructureParts() {
		List<IPrintable> result = new ArrayList<>();
		result.addAll(items);
		return result;
	}



	@Override
	public String getPrintLabel() {
		return null;
	}



	@Override
	public String getPrintArgs() {
		return null;
	}



	@Override
	public String getPrintComment() {
		return null;
	}



	@Override
	public int getSize() {
		return items.size();
	}



	@Override
	public AbstractInstruction get(int index) {
		return items.get(index);
	}



	@Override
	public int indexOf(AbstractInstruction item) {
		return items.indexOf(item);
	}



	@Override
	protected void doResolve() {
		setOffsets();
		for (AbstractInstruction instr: items) {
			instr.resolve();
		}
		
	}



	@Override
	public int getItemSizeInList(IBytecodeItem item) {
		return 1;
	}



	
	

}