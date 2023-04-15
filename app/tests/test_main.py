import pytest
import json
from main.main import app

def test_get_root():
    response = app.test_client().get('/')
    res = json.loads(response.data.decode('utf-8'))
    assert response.status_code == 200
    assert type(res) is dict
    assert res['message'] == 'Automate all the things!'