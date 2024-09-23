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
        basePackages = "com.henry.democloudsql.repository",
        entityManagerFactoryRef = "pscEntityManager",
        transactionManagerRef = "pscTransactionManager"
)
public class PSCpostgresConfig {

    @Value("${spring.datasource.psc.url}")
    private  String url;
    @Value("${spring.datasource.psc.database}")
    private String database;
    @Value("${spring.datasource.psc.cloudSqlInstance}")
    private  String cloudSqlInstance;
    @Value("${spring.datasource.psc.username}")
    private String username;

    @Value("${spring.datasource.psc.password}")
    private String password;
    @Value("${spring.datasource.psc.ipTypes}")
    private String ipTypes;
    @Value("${spring.datasource.psc.socketFactory}")
    private String socketFactory;
    @Value("${spring.datasource.psc.driverClassName}")
    private String driverClassName;
    @Bean
    @Primary
    public LocalContainerEntityManagerFactoryBean pscEntityManager()
            throws NamingException {
        LocalContainerEntityManagerFactoryBean em
                = new LocalContainerEntityManagerFactoryBean();
        em.setDataSource(pscDataSource());
        em.setPackagesToScan("com.henry.democloudsql.model");

        JpaVendorAdapter vendorAdapter = new HibernateJpaVendorAdapter();
        em.setJpaVendorAdapter(vendorAdapter);
        em.setJpaProperties(pscHibernateProperties());

        return em;
    }
    @Bean
    @Primary
    public DataSource pscDataSource() throws IllegalArgumentException {
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
    private Properties pscHibernateProperties() {
        Properties properties = new Properties();
        return properties;
    }
    @Bean
    @Primary
    public PlatformTransactionManager pscTransactionManager() throws NamingException {
        final JpaTransactionManager transactionManager = new JpaTransactionManager();
        transactionManager.setEntityManagerFactory(pscEntityManager().getObject());
        return transactionManager;
    }
}
