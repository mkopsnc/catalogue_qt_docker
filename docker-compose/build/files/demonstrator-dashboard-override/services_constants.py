SERVER_IP = 'server'
SERVER_PORT = '8080'
API_ROOT = f'http://{SERVER_IP}:{SERVER_PORT}/'

PAGE_SIZE = 10

MAIN_VARIABLES = ['ids_properties/creation_date', 'global_quantities/ip/value', 'global_quantities/b0/value', 'global_quantities/q_95/value', 'global_quantities/power_ohm/value']
PARAMETERS_CONDITIONS_MAP = {'start_date': {'idsField': 'ids_properties/creation_date', 'condition':'>='},
                             'end_date': {'idsField':'ids_properties/creation_date', 'condition':'<='},
                             'ip_min': {'idsField':'global_quantities/ip/value', 'condition':'>='},
                             'ip_max': {'idsField':'global_quantities/ip/value', 'condition':'<='},
                             'b0_min': {'idsField':'global_quantities/b0/value', 'condition':'>='},
                             'b0_max': {'idsField':'global_quantities/b0/value', 'condition':'<='},
                             'q95_min': {'idsField':'global_quantities/q_95/value', 'condition':'>='},
                             'q95_max': {'idsField':'global_quantities/q_95/value', 'condition':'<='},
                             'power_ohm_min': {'idsField':'global_quantities/power_ohm/value', 'condition':'>='},
                             'power_ohm_max': {'idsField':'global_quantities/power_ohm/value', 'condition':'<='}
                    }
