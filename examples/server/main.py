#  Copyright 2022 Google LLC
# 
#  Licensed under the Apache License, Version 2.0 (the "License");
#  you may not use this file except in compliance with the License.
#  You may obtain a copy of the License at
# 
#      https:# www.apache.org/licenses/LICENSE-2.0
# 
#  Unless required by applicable law or agreed to in writing, software
#  distributed under the License is distributed on an "AS IS" BASIS,
#  WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
#  See the License for the specific language governing permissions and
#  limitations under the License.

from http.server import BaseHTTPRequestHandler, HTTPServer
import time
import cgi
import json
import requests


DEFAULT_HOST_NAME = "localhost"
DEFAULT_SERVER_PORT = 8080
CLOUD_PROJECT_NUMBER = "CLOUD_PROJECT_NUMBER"
API_KEY = "API_KEY"

RECAPTCHA_FULL_URL = f"https://recaptchaenterprise.googleapis.com/v1/projects/{CLOUD_PROJECT_NUMBER}/assessments?key={API_KEY}"

class DemoServer(BaseHTTPRequestHandler):

    def _fetch_assessment(self, token: str, site_key: str) -> dict:
        response = requests.post(RECAPTCHA_FULL_URL,
            json = {'event': {'token':token, 'siteKey': site_key}},
        )
        json_response = json.loads(response.text)
        return json_response

    def _should_block(self, score: float) -> bool: 
        if score < 0.5:
            return True
        else:
            return False

    def do_POST(self):
        
        if self.path == "/login":
            ctype, pdict = cgi.parse_header(self.headers.get('content-type'))
        
            if ctype != 'application/json':
                self.send_response(400)
                self.end_headers()
                return

            length = int(self.headers.get('content-length'))
            content = json.loads(self.rfile.read(length))
            print(f"Received request: {json.dumps(content, indent=4)}")
            
            assessment = self._fetch_assessment(content['token'], content['siteKey'])
            print(f"Retrieved assessment: {json.dumps(assessment, indent=4)}")

            response = json.dumps({'shouldBlock': self._should_block(assessment['riskAnalysis']['score'])})
            self.send_response(200)
            self.send_header('Content-type', 'application/json')
            self.end_headers()
            print(f"Response: {response}")
            self.wfile.write(response.encode('utf-8'))

if __name__ == "__main__":        
    webServer = HTTPServer((DEFAULT_HOST_NAME, DEFAULT_SERVER_PORT), DemoServer)
    print(f"Server started http:# {DEFAULT_HOST_NAME}:{DEFAULT_SERVER_PORT}")

    try:
        webServer.serve_forever()
    except KeyboardInterrupt:
        pass

    webServer.server_close()
    print("Server stopped.")