module FileData
  # Contains tag number to name information taken from the exif spec
  module ExifTags
    EXIF =
      {
        256 => :Image_Structure_Width,
        257 => :Image_Structure_Length,
        258 => :Image_Structure_BitsPerSample,
        259 => :Image_Structure_Compression,
        262 => :Image_Structure_PhotometricInterpretation,
        274 => :Image_Structure_Orientation,
        277 => :Image_Structure_SamplesPerPixel,
        284 => :Image_Structure_PlanarConfiguration,
        530 => :Image_Structure_YCbCrSubSampling,
        531 => :Image_Structure_YCbCrPositioning,
        283 => :Image_Structure_YResolution,
        296 => :Image_Structure_ResolutionUnit,

        273 => :Recording_StripOffsets,
        278 => :Recording_RowsPerStrip,
        279 => :Recording_StripByteCounts,
        513 => :Recording_JPEGInterchangeFormat,
        514 => :Recording_JPEGInterchangeFormatLength,

        301 => :Image_Data_TransferFunction,
        318 => :Image_Data_WhitePoint,
        319 => :Image_Data_PrimaryChromaticities,
        529 => :Image_Data_YCbCrCoefficients,
        532 => :Image_Data_ReferenceBlackWhite,

        306 => :Other_DateTime,
        270 => :Other_ImageDescription,
        271 => :Other_Make,
        272 => :Other_Model,
        305 => :Other_Software,
        315 => :Other_Artist,
        33_432 => :Other_Copyright,

        36_864 => :Exif_Version_ExifVersion,
        40_960 => :Exif_Version_FlashpixVersion,

        40_961 => :Exif_ColorSpace_ColorSpace,
        42_240 => :Exif_ColorSpace_Gamma,

        40_962 => :Exif_Configuration_PixelXDimension,
        40_963 => :Exif_Configuration_PixelYDimension,
        37_121 => :Exif_Configuration_ComponentsConfiguration,
        37_122 => :Exif_Configuration_CompressedBitsPerPixel,
        37_500 => :Exif_Configuration_MakerNote,
        37_510 => :Exif_Configuration_UserComment,

        40_964 => :Exif_RelatedFile_RelatedSoundFile,

        36_867 => :Exif_DateAndTime_DateTimeOriginal,
        36_868 => :Exif_DateAndTime_DateTimeDigitized,
        37_520 => :Exif_DateAndTime_SubsecTime,
        37_521 => :Exif_DateAndTime_SubsecTimeOriginal,
        37_522 => :Exif_DateAndTime_SubsecTimeDigitized,

        33_434 => :Exif_PictureTakingConditions_ExposureTime,
        33_437 => :Exif_PictureTakingConditions_FNumber,
        34_850 => :Exif_PictureTakingConditions_ExposureProgram,
        34_852 => :Exif_PictureTakingConditions_SpectralSensitivity,
        34_855 => :Exif_PictureTakingConditions_PhotographicSensitivity,
        34_856 => :Exif_PictureTakingConditions_OECF,
        34_864 => :Exif_PictureTakingConditions_SensitivityType,
        34_865 => :Exif_PictureTakingConditions_StandardOutputSensitivity,
        34_866 => :Exif_PictureTakingConditions_RecommendedExposureIndex,
        34_867 => :Exif_PictureTakingConditions_ISOSpeed,
        34_868 => :Exif_PictureTakingConditions_ISOSpeedLatitudeyyy,
        34_869 => :Exif_PictureTakingConditions_ISOSpeedLatitudezzz,
        37_377 => :Exif_PictureTakingConditions_ShutterSpeedValue,
        37_378 => :Exif_PictureTakingConditions_ApertureValue,
        37_379 => :Exif_PictureTakingConditions_BrightnessValue,
        37_380 => :Exif_PictureTakingConditions_ExposureBiasValue,
        37_381 => :Exif_PictureTakingConditions_MaxApertureValue,
        37_382 => :Exif_PictureTakingConditions_SubjectDistance,
        37_383 => :Exif_PictureTakingConditions_MeteringMode,
        37_384 => :Exif_PictureTakingConditions_LightSource,
        37_385 => :Exif_PictureTakingConditions_Flash,
        37_396 => :Exif_PictureTakingConditions_SubjectArea,
        37_386 => :Exif_PictureTakingConditions_FocalLength,
        41_483 => :Exif_PictureTakingConditions_FlashEnergy,
        41_484 => :Exif_PictureTakingConditions_SpatialFrequencyResponse,

        41_486 => :Exif_PictureTakingConditions_FocalPlaneXResolution,
        41_487 => :Exif_PictureTakingConditions_FocalPlaneYResolution,
        41_488 => :Exif_PictureTakingConditions_FocalPlanResolutionUnit,
        41_492 => :Exif_PictureTakingConditions_SubjectLocation,
        41_493 => :Exif_PictureTakingConditions_ExposureIndex,
        41_495 => :Exif_PictureTakingConditions_SensingMode,
        41_728 => :Exif_PictureTakingConditions_FileSource,
        41_729 => :Exif_PictureTakingConditions_SceneType,
        41_730 => :Exif_PictureTakingConditions_CFAPattern,
        41_985 => :Exif_PictureTakingConditions_CustomRendered,
        41_986 => :Exif_PictureTakingConditions_ExposureMode,
        41_987 => :Exif_PictureTakingConditions_WhiteBalance,
        41_988 => :Exif_PictureTakingConditions_DigitalZoomRatio,
        41_989 => :Exif_PictureTakingConditions_FocalLengthIn35mmFilm,
        41_990 => :Exif_PictureTakingConditions_SceneCaptureType,
        41_991 => :Exif_PictureTakingConditions_GainControl,
        41_992 => :Exif_PictureTakingConditions_Contrast,
        41_993 => :Exif_PictureTakingConditions_Saturation,
        41_994 => :Exif_PictureTakingConditions_Sharpness,
        41_995 => :Exif_PictureTakingConditions_DeviceSettingDescription,
        41_996 => :Exif_PictureTakingConditions_SubjectDistanceRange
      }.freeze
  end
end
