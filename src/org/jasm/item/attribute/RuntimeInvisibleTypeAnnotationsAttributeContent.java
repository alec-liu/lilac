package org.jasm.item.attribute;

import org.jasm.bytebuffer.IByteBuffer;




public class RuntimeInvisibleTypeAnnotationsAttributeContent extends
		AbstractAnnotationsAttributeContent {

	@Override
	public String getPrintName() {
		return null;
	}
	
	@Override
	protected Annotation createEmptyItem(IByteBuffer source, long offset) {
		Annotation result = super.createEmptyItem(source, offset); 
		result.setTypeAnnotation(true);
		return result;
	}

	

}
