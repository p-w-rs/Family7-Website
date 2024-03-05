import smtplib
from email.mime.text import MIMEText
from email.mime.multipart import MIMEMultipart
from email.mime.application import MIMEApplication
import os

class EmailSender:
    def __init__(self, host, port, username, password, cafile):
        self.host = host
        self.port = int(port)
        self.username = username
        self.password = password
        self.cafile = cafile

        self.smtp_server = smtplib.SMTP(self.host, self.port)
        self.smtp_server.starttls()
        self.smtp_server.login(self.username, self.password)      

    def send_email(self, from_name, sender_addr, receiver_addr, subject, message, attachments=None):
        msg = MIMEMultipart()
        msg['From'] = f"{from_name} <{sender_addr}>"
        msg['To'] = receiver_addr
        msg['Subject'] = subject

        msg.attach(MIMEText(message, 'plain'))

        if attachments:
            for attachment in attachments:
                with open(attachment, 'rb') as file:
                    part = MIMEApplication(file.read(), Name=os.path.basename(attachment))
                    part['Content-Disposition'] = f'attachment; filename="{os.path.basename(attachment)}"'
                    msg.attach(part)

        self.smtp_server.sendmail(sender_addr, receiver_addr, msg.as_string())


    def close_server(self):
        self.smtp_server.quit()
