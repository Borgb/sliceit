local device = { model_name = system.getInfo( "model" ) }
device.scale_mode = "letterbox"

if ( string.sub( device.model_name, 1, 4 ) == "iPad" ) then
	-- iPad
	device.width = 384
	device.height = 512

elseif ( string.sub( device.model_name, 1, 2 ) == "iP" and display.pixelHeight > 960 ) then
	-- iPhone5
	device.width = 320
	device.height = 568

elseif ( string.sub( device.model_name, 1, 2 ) == "iP" ) then
	--iPhone4 & older
	device.width = 320
		device.height = 480

elseif ( display.pixelHeight / display.pixelWidth > 1.72 ) then
	-- Android 16:9 ratio devices
	device.width = 320
	device.height = 570
	device.scale_mode = "zoomStretch"

else
	-- other Android devices
	device.width = 320
	device.height = 512
	device.scale_mode = "zoomStretch"

end

-- define the application details

application = 
	{
	content = 
		{
		width = device.width,
		height = device.height,
		scale = device.scale_mode,
		xAlign = "center",
		yAlign = "center",
		fps = 30,
		imageSuffix = 
			{
				["@2x"] = 1.5,
			},

		},

		notification = { 
			iphone = {
			types =  { "badge", "sound", "alert" }
					}	
				}
		}
