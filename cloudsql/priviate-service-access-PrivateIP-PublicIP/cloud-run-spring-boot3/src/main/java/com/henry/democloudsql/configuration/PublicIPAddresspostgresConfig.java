package com.henry.democloudsql.configuration;

import com.zaxxer.hikari.HikariConfig;
import com.zaxxer.hikari.HikariDataSource;
import org.springframework.beans.factory.annotation.Value;
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
        basePackages = "com.henry.democloudsql.repository.publicip",
        entityManagerFactoryRef = "mySchemaPublicIPEntityManager",
        transactionManagerRef = "mySchemaPublicIPTransactionManager"
)
public class PublicIPAddresspostgresConfig {

    @Value("${spring.datasource.public-ip.url}")
    private  String url;
    @Value("${spring.datasource.public-ip.database}")
    private String database;
    @Value("${spring.datasource.public-ip.cloudSqlInstance}")
    private  String cloudSqlInstance;
    @Value("${spring.datasource.public-ip.username}")
    private String username;

    @Value("${spring.datasource.public-ip.password}")
    private String password;
    @Value("${spring.datasource.public-ip.ipTypes}")
    private String ipTypes;
    @Value("${spring.datasource.public-ip.socketFactory}")
    private String socketFactory;
    @Value("${spring.datasource.public-ip.driverClassName}")
    private String driverClassName;

    @Bean
    @Primary
    public LocalContainerEntityManagerFactoryBean mySchemaPublicIPEntityManager()
            throws NamingException {
        LocalContainerEntityManagerFactoryBean em
                = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(mySchemaPublicIPDataSource());
        em.setPackagesToScan("com.henry.democloudsql.model.publicip");

        JpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        em.setJpaVendorAdapter(vendorAdapter);
        em.setJpaProperties(mySchemaPublicIPHibernateProperties());

        return em;
    }

    @Bean
    @Primary
    public DataSource mySchemaPublicIPDataSource() throws IllegalArgumentException {
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

    private Properties mySchemaPublicIPHibernateProperties() {
        Properties properties = new Properties();
        return properties;
    }

    @Primary
    @Bean
    public PlatformTransactionManager mySchemaPublicIPTransactionManager() throws NamingException {
        final JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(mySchemaPublicIPEntityManager().getObject());
        return transactionManager;
    }
}
