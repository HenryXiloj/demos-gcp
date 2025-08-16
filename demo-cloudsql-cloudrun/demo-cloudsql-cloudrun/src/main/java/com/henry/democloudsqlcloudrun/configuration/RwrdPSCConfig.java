package com.henry.democloudsqlcloudrun.configuration;


import com.zaxxer.hikari.HikariDataSource;
import org.springframework.boot.context.properties.ConfigurationProperties;
import org.springframework.boot.jdbc.DataSourceBuilder;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
import org.springframework.context.annotation.Primary;
import org.springframework.data.jpa.repository.config.EnableJpaRepositories;
import org.springframework.orm.jpa.JpaTransactionManager;
import org.springframework.orm.jpa.JpaVendorAdapter;
import org.springframework.orm.jpa.LocalContainerEntityManagerFactoryBean;
import org.springframework.orm.jpa.vendor.HibernateJpaVendorAdapter;
import org.springframework.transaction.PlatformTransactionManager;

import javax.naming.NamingException;
import javax.sql.DataSource;
import java.util.Properties;

@Configuration
@EnableJpaRepositories(
        basePackages = "com.henry.democloudsqlcloudrun.repository",
        entityManagerFactoryRef = "rwrdEntityManager",
        transactionManagerRef = "rwrdTransactionManager"
)
public class RwrdPSCConfig {


    @Bean
    @Primary
    public LocalContainerEntityManagerFactoryBean rwrdEntityManager()
            throws NamingException {
        LocalContainerEntityManagerFactoryBean em
                = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(dataSource());
        em.setPackagesToScan("com.henry.democloudsqlcloudrun.model");

        JpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        em.setJpaVendorAdapter(vendorAdapter);
        em.setJpaProperties(rwrdHibernateProperties())
        ;

        return em;
    }

    /**
     * PRIVATE SERVICE CONNECT
     */
    @Bean
    @Primary
    @ConfigurationProperties(prefix = "spring.datasource")
    public DataSource dataSource() throws IllegalArgumentException {
        return DataSourceBuilder.create().type(HikariDataSource.class).build();
    }

    private Properties rwrdHibernateProperties() {
        Properties properties = new Properties();
        return properties;
    }

    @Bean
    @Primary
    public PlatformTransactionManager rwrdTransactionManager() throws NamingException {
        final JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(rwrdEntityManager().getObject());
        return transactionManager;
    }
}
