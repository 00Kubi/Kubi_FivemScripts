Config = {}

Config.Drugs = {
    Kokaina = {
        harvestLocation = vector3(220.0, -810.0, 30.0),
        processLocation = vector3(230.0, -810.0, 30.0),
        harvestTime = 1,
        processTime = 10,
        harvestItem = 'lisc_kokainy',
        processedItem = 'torebka_kokainy',
        processAnimation = 'amb@prop_human_bum_bin@base',
        explosionChance = 0
    },
    Metaamfetamina = {
        harvestLocation = vector3(250.0, -800.0, 30.0),
        processLocation = vector3(260.0, -800.0, 30.0),
        harvestTime = 1,
        processTime = 15,
        harvestItem = 'surowa_metaamfetamina',
        processedItem = 'gotowa_metaamfetamina',
        processAnimation = 'anim@amb@business@meth@meth_monitoring_cooking@cooking@',
        explosionChance = 0.10
    }
    -- Add More
}
