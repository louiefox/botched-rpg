local panelMeta = FindMetaTable( "Panel" )

function panelMeta:CreateFadeAlpha( hoverDuration, hoverAlpha, decreaseDuration, decreaseAlpha, extraEnabled, extraAlpha, extraDuration )
    hoverAlpha = hoverAlpha or 255
    decreaseAlpha = decreaseAlpha or 0
    extraAlpha = extraAlpha or 255

    hoverDuration = hoverDuration or (hoverAlpha/255)*0.2
    decreaseDuration = decreaseDuration or 0.2
    extraDuration = extraDuration or (extraAlpha/255)*0.2

    if( not self.alpha ) then
        self.alpha = 0
    end

    if( extraEnabled ) then
        if( not self.extraEndTime ) then
            self.hoverEndTime = nil
            self.decreaseEndTime = nil
            self.extraEndTime = CurTime()+extraDuration
        end

        self.alpha = math.Clamp( (extraDuration-(self.extraEndTime-CurTime()))/extraDuration, 0, 1 )*extraAlpha
    elseif( self:IsHovered() ) then
        if( not self.hoverEndTime ) then
            self.extraEndTime = nil
            self.decreaseEndTime = nil
            self.hoverEndTime = CurTime()+hoverDuration
        end

        self.alpha = math.Clamp( (hoverDuration-(self.hoverEndTime-CurTime()))/hoverDuration, 0, 1 )*hoverAlpha
    else
        if( not self.decreaseEndTime ) then
            self.hoverEndTime = nil
            self.extraEndTime = nil
            self.decreaseEndTime = CurTime()+decreaseDuration
        end

        self.alpha = Lerp( math.Clamp( (decreaseDuration-(self.decreaseEndTime-CurTime()))/decreaseDuration, 0, 1 ), self.alpha, decreaseAlpha )
    end
end