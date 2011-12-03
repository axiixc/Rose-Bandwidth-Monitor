The Notification Provider interface allows custom notification handling code to be easily added to RBM. The `boxcar.rb` provider is considered part of the base RBM distribution, and is a good example use of the interface.

# Understanding Notification Flow in RBM

RBM will handle all scraping, processing, and storage of information. Notifications are seen as a separate part of this process, in which RBM will reach out to 3rd party code to handle notification delivery. As such Notification Providers function through a callback-style API. When an appropriate [trigger](Notification-Triggers) is hit for a given user RBM will query for any active `UserNotificationProvider`s. Assuming one or more is found, RBM will invoke their `notify` method with the appropriate notification hash. From here notification processing is entirely in the hands of the providers, and RBM will take no further action.

# Implementing a Notification Provider

The primary classes involved in notification are `UserNotificationProvider` and `UserNotificationProviderDelegate` subclasses. However, only the `UserNotificationProviderDelegate` subclass needs implemented, while the `UserNotificationProvider` will be managed by RBM.

Notification providers should be placed in the `notification_providers` subdirectory within the RBM installation. The server will automatically require all files in this directory before execution begins. A provider should include in its file a delegate subclass and a registration call.

`UserNotificationProviderDelegate` instances are initialized with a `User` and a `UserNotificationProvider`. These field can be accessed via `self.user` and `self.provider`. Subclasses should optionally override the following methods.

* `::configuration_options` which returns an array of configuration options used to assemble a UI for users to configure the provider.
* `#subscribe` which is called every time the provider is switched from inactive to active.
* `#unsubscribe` which is called every time the provider is switched from active to inactive.
* `#notify` which is called every time a notification is triggered in RBM.

## ::configuration_options &rarr; Array
This method can also be called on an instance of the provider delegate, however since the instance method only forwards the call to the class, it is recommended not to be touched.

The configuration array returned can contain any number of configuration hashes (or none). Available configuration controls are `:text`, `:password`, and `:checkbox`. Additionally a name and label can be specified.

An example configuration hash.

	[
		{ :type => :text, :name => :text, :label => "Text" },
		{ :type => :password, :name => :password, :label => "Password" },
		{ :type => :checkbox, :name => :checkbox, :label => "Checkbox" }
	]

## subscribe and unsubscribe
These method returns nothing and takes no parameters. Any additional state should be taken from the user or provider fields. This method may be called multiple times if a user opts in and out of a service, if you wish to only preform actions once keep track of them manually via the provider's configuration options.

**Note:** no guarantee is made that a `subscribe` or `unsubscribe` call can not duplicate. The owning `UserNotificaitonProvider` may be deleted, losing state information. You should use an API that can handle multiple subscription requests.

## notify( notification )
This method is called whenever a notification is triggered. It provides no return value, and is passed a notification hash with the following values.

* `notification[:type]` - the trigger type for the notification, valid values are `:warn_level`, and `:bandwidth_class`.
* `notification[:entry]` - the `MainBandwidthEntry` object which triggered the notification

# Registering a Notification Provider

Notification Providers require a name, identifier, and class, and register themselves with RBM by means of the `Rose::User.register_notification_provider` method. For example, the included boxcar provider registers itself as follows:

	Rose::User::register_notification_provider("Boxcar", "com.axiixc.rbm.boxcar", BoxcarAPINotificationProvider)

The identifier must be unique, otherwise an exception will be raised. Thus is also recommended to use reverse DNS notation. Once a service has been registered it cannot be removed without restarting RBM.

# Handling for Missing Providers

If a provider is added to a system and configured, and then removed, no special actions will be taken. When a notification is generated, if the `UserNotificationProvider` cannot find its delegate it will silently fail. The advantage of this is that if at some point the same provider is brought back, operations will resume as expected.

Similarly, if a user disables a provider or enters configuration data but does not enable the service, an appropriate provider will still be created and persist.