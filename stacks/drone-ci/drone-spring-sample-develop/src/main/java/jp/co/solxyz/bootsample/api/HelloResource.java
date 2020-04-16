package jp.co.solxyz.bootsample.api;

import javax.ws.rs.GET;
import javax.ws.rs.Path;

import org.springframework.stereotype.Component;

@Component
@Path("/")
public class HelloResource {

	@GET
	public String get() {
		return "Hello World!";
	}
}
