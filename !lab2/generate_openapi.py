import yaml
from app.main import app
openapi_schema = app.openapi()
with open("openapi.yaml", "w", encoding="utf-8") as f:
    yaml.dump(openapi_schema, f, allow_unicode=True)