from argparse import ArgumentParser

from uvicorn import run

from src.create_app import create_app

arg_parser = ArgumentParser(description="Args with custom host and port settings.")
arg_parser.add_argument("--host", dest="host", default="0.0.0.0")
arg_parser.add_argument("--port", dest="port", default=8000, type=int)
args = arg_parser.parse_args()


if __name__ == "__main__":
    app = create_app()
    run(app, host=args.host, port=args.port)
