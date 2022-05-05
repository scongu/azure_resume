import logging
import azure.functions as func

def main(req: func.HttpRequest, read: func.DocumentList, write: func.Out[func.Document]) -> func.HttpResponse:
    logging.info('Website found')

    if not read:
        logging.warning("No counter")
        return func.HttpResponse("No counter",status_code=500)
    
    else:
        logging.info("Found Counter")
        read[0]['count'] = read[0]['count'] + 1
        write.set(read[0])
        return func.HttpResponse(str(read[0]['count']),status_code=200)