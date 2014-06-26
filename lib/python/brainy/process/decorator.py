from brainy.process import BrainyProcessError


def require_keys_in_description(*description_keys):
    '''
    Apply this decorator to process class if you want to require process
    descriptor to contain particular keys. Notice that this will inject
    respective *property* into the process description.
    '''

    def add_required_property(obj_instance, property_name):
        assert not hasattr(obj_instance, property_name)

        def get_required_description_key(self, ):
            '''Require process descriptor to contain: %s''' % property_name
            try:
                return self.description[property_name]
            except KeyError:
                raise BrainyProcessError(
                    'Missing "%s" key in JSON descriptor of the process.' %
                    property_name
                )

        setattr(obj_instance, property_name,
                property(get_required_description_key))

    def class_builder(original_class):
        orig_init = original_class.__init__

        def __init__(self, *args, **kws):
            for key in description_keys:
                add_required_property(self, key)
            orig_init(self, *args, **kws)

        original_class.__init__ = __init__
        return original_class

    return class_builder
