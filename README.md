# Small part of Hydra User Private Office application (aka HUPO)

It hosts here for convenience only.

Widget is just a specific model for interface customization. At present settings of every widget are stored in YML files. But in future they can be transparently moved to DB.

### Example

Put widget class in app/widgets.

```ruby
class SupportWidget < HupoWidget::Base
  singleton! # Only one widget of this type allowed
end
```

Create corresponding YML-file in config/widgets.

```yml
common:
  vc_support_phone: 777-55-33
```

Now you have model object.

```ruby
widget = SupportWidget.instance

widget['vc_support_phone'] # "777-55-33"
widget.as_json # {vc_support_phone: "777-55-33"}
```

Simple!
