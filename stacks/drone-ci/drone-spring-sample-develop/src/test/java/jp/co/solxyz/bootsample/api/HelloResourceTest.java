package jp.co.solxyz.bootsample.api;

import static org.junit.Assert.*;
import static org.hamcrest.CoreMatchers.*;

import org.junit.Test;

public class HelloResourceTest {

	/** Testing Target */
	HelloResource target = new HelloResource();
	
	/**
	 * Sample Test Case
	 */
	@Test
	public void test() {
		
		assertThat("Hello World!", is(target.get()));
	}

}
