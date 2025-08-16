package com.henry.democloudsqlcloudrun.util;

import com.jcraft.jsch.*;

import java.io.BufferedReader;
import java.io.InputStream;
import java.io.InputStreamReader;

public class SSHFileReader {

    public static String readFile(String host, String username, String password, String filePath) {
        JSch jsch = new JSch();
        Session session = null;
        StringBuilder fileContent = new StringBuilder();

        try {
            session = jsch.getSession(username, host, 22);
            session.setPassword(password);
            session.setConfig("StrictHostKeyChecking", "no");
            session.connect();

            Channel channel = session.openChannel("exec");
            ((ChannelExec) channel).setCommand("cat " + filePath); // Command to read file content
            channel.setInputStream(null);
            ((ChannelExec) channel).setErrStream(System.err);

            InputStream in = channel.getInputStream();
            channel.connect();

            BufferedReader reader = new BufferedReader(new InputStreamReader(in));
            String line;
            while ((line = reader.readLine()) != null) {
                fileContent.append(line).append("\n");
            }

            channel.disconnect();
            session.disconnect();
        } catch (JSchException | java.io.IOException e) {
            e.printStackTrace();
        }

        return fileContent.toString();
    }
}
