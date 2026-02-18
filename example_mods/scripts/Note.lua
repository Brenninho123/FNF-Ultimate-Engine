local playState = 'states.PlayState'
local is07 = false

local splashOffsetX = 0
local splashOffsetY = 0

function onCreate()
    if version < '0.7' then
        playState = 'PlayState'
    else
        is07 = true
        setPropertyFromClass(playState,'SONG.disableNoteRGB',true)
    end


    local noteSkin = getPropertyFromClass(playState,'SONG.arrowSkin')
    if noteSkin == nil or noteSkin == '' or noteSkin == 'NOTE_assets' then
        setPropertyFromClass(playState,'SONG.arrowSkin','noteSkins/NOTE_assets')
    end

    local splashSkin = getPropertyFromClass(playState,'SONG.splashSkin')
    if splashSkin == nil or splashSkin == '' or splashSkin == 'noteSplashes' then
        splashSkin = 'noteSplashes/noteSplashes'
        setPropertyFromClass(playState,'SONG.splashSkin', splashSkin)
    end

    precacheImage(splashSkin)
end


function onDestroy()
    setPropertyFromClass(playState,'SONG.arrowSkin','')
    setPropertyFromClass(playState,'SONG.splashSkin','')

    if version > '0.6.3' then
        setPropertyFromClass('states.PlayState','SONG.disableNoteRGB',false)
    end
end

local function getSickWindow()
    if version > '0.6.3' then
        return getPropertyFromClass('backend.ClientPrefs','data.sickWindow')
    else
        return getPropertyFromClass('ClientPrefs','sickWindow')
    end
end


function goodNoteHit(id,data,type,sus)
    if sus then return end

    local noteDiff = math.abs(getPropertyFromGroup('notes',id,'strumTime') - getSongPosition())
    if noteDiff > getSickWindow() then return end

    for splashes = 0, getProperty('grpNoteSplashes.length')-1 do

        setPropertyFromGroup('grpNoteSplashes',splashes,'scale.x',1)
        setPropertyFromGroup('grpNoteSplashes',splashes,'scale.y',1)

        setPropertyFromGroup('grpNoteSplashes',splashes,'offset.x', splashOffsetX)
        setPropertyFromGroup('grpNoteSplashes',splashes,'offset.y', splashOffsetY)

        if is07 then
            setPropertyFromGroup('grpNoteSplashes',splashes,'shader', nil)

            setPropertyFromGroup(
                'grpNoteSplashes',
                splashes,
                'alpha',
                getPropertyFromClass('backend.ClientPrefs','data.splashAlpha')
                * getPropertyFromGroup('playerStrums',data,'alpha')
            )
        else
            setPropertyFromGroup(
                'grpNoteSplashes',
                splashes,
                'alpha',
                0.8 * getPropertyFromGroup('playerStrums',data,'alpha')
            )
        end
    end
end
