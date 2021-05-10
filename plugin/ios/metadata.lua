local metadata =
{
	plugin =
	{
		format = 'staticLibrary',
		staticLibs = { 'plugin_adjust' },
		frameworks = { 'AdSupport', 'CoreTelephony', 'StoreKit', },
		frameworksOptional = { 'AppTrackingTransparency', },
		-- usesSwift = true,
	},
}

return metadata
