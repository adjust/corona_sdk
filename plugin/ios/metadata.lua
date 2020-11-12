local metadata =
{
	plugin =
	{
		format = 'staticLibrary',
		staticLibs = { 'plugin_adjust' },
		frameworks = { 'AdSupport', 'CoreTelephony', 'StoreKit', 'AppTrackingTransparency'},
		frameworksOptional = {},
		-- usesSwift = true,
	},
}

return metadata
