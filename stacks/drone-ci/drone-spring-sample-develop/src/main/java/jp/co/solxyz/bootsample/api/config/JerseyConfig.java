package jp.co.solxyz.bootsample.api.config;

import javax.ws.rs.ApplicationPath;

import org.glassfish.jersey.server.ResourceConfig;
import org.springframework.stereotype.Component;

@Component
@ApplicationPath("/rs")
public class JerseyConfig extends ResourceConfig{

	public JerseyConfig() {
		packages("jp.co.solxyz.bootsample.api");
	}
}
