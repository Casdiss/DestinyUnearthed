-- Horticopia Paradise Banquet
local s,id=GetID()
function s.initial_effect(c)
	e1=Ritual.AddProcGreater({handler=c,filter=s.ritualfil})
	e1:SetCondition(s.condition)
end
function s.ritualfil(c)
	return c:IsSetCard(0x888) and c:IsRitualMonster()
end
function s.condition(e,tp)
	local fld=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fld then
		return fld:IsSetCard(0x888)
	end
end