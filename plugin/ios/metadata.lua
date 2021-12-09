local metadata =
{
	plugin =
	{
		format = 'staticLibrary',
		staticLibs = { 'plugin_adjust' },
		frameworks = { 'AdSupport', 'CoreTelephony', 'StoreKit', },
		frameworksOptional = { 'AppTrackingTransparency', 'AdServices', 'iAd' },
		-- usesSwift = true,
	},
}

return metadata
