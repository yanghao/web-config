def application(env, start_response):
    start_response('200 OK', [('Content-Type', 'text/html')])
    return "Coding since 2005. %s" % env['REQUEST_URI']
