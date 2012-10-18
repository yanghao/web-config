from mako.template import Template
from tornado import web
from tornado import wsgi

class MainHandler(web.RequestHandler):
    def get(self):
        self.write("Hello World tornado!")

url = [ (r'/', MainHandler),
]

application = wsgi.WSGIApplication(url)
