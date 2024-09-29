package com.henry.democloudsql.configuration;


import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.beans.factory.annotation.Value;
import org.springframework.context.annotation.Bean;
import org.springframework.context.annotation.Configuration;
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
        basePackages = "com.henry.democloudsql.repository.privateipvpc",
        entityManagerFactoryRef = "mySchemaVpcEntityManager",
        transactionManagerRef = "mySchemaVpcTransactionManager"
)
public class PrivateIPAddressVPCpostgresConfig {

    @Value("${spring.datasource.private-ip.url}")
    private String url;
    @Value("${spring.datasource.private-ip.database}")
    private String database;
    @Value("${spring.datasource.private-ip.cloudSqlInstance}")
    private String cloudSqlInstance;
    @Value("${spring.datasource.private-ip.username}")
    private String username;
    @Value("${spring.datasource.private-ip.password}")
    private String password;
    @Value("${spring.datasource.private-ip.ipTypes}")
    private String ipTypes;
    @Value("${spring.datasource.private-ip.socketFactory}")
    private String socketFactory;
    @Value("${spring.datasource.private-ip.driverClassName}")
    private String driverClassName;

    @Bean
    public LocalContainerEntityManagerFactoryBean mySchemaVpcEntityManager() {
        LocalContainerEntityManagerFactoryBean em
                = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(mySchemaVpcDataSource());
        em.setPackagesToScan("com.henry.democloudsql.model.privateipvpc");

        JpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        em.setJpaVendorAdapter(vendorAdapter);
        em.setJpaProperties(mySchemaVpcHibernateProperties());

        return em;
    }

    @Bean
    public DataSource mySchemaVpcDataSource() throws IllegalArgumentException {

        HikariConfig config = new HikariConfig();

        config.setJdbcUrl(String.format(url + "%s", database));
        config.setUsername(username);
        config.setPassword(password);

        config.addDataSourceProperty("socketFactory", socketFactory);
        config.addDataSourceProperty("cloudSqlInstance", cloudSqlInstance);

        config.addDataSourceProperty("ipTypes", ipTypes);

        config.setMaximumPoolSize(5);
        config.setMinimumIdle(5);
        config.setConnectionTimeout(10000);
        config.setIdleTimeout(600000);
        config.setMaxLifetime(1800000);

        return new HikariDataSource(config);

    }

    private Properties mySchemaVpcHibernateProperties() {
        Properties properties = new Properties();
        return properties;
    }
    @Bean
    public PlatformTransactionManager mySchemaVpcTransactionManager() throws NamingException {
        final JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(mySchemaVpcEntityManager().getObject());
        return transactionManager;
    }
}

