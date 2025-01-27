-- Horticopia Melonolana 
local s, id = GetID()
function s.initial_effect(c) 
	--Become a Field Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SUMMON_SUCCESS)
	e1:SetOperation(s.smnop)
	c:RegisterEffect(e1)
	local e2=e1:Clone()
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	c:RegisterEffect(e2)
	--Apply Queen Ambrosé's effect, then add 2 "Horticopia Garden Harvest" from Deck or GY
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SEARCH+CATEGORY_TOHAND)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_MOVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e) return e:GetHandler():IsLocation(LOCATION_FZONE) end)
	e3:SetCost(s.fldcost)
	e3:SetTarget(s.fldtg)
	e3:SetOperation(s.fldop)
	c:RegisterEffect(e3)
end
function s.smnop(e,tp,eg,ep,ev,re,r,rp)
	--Become a Field Spell
	local c=e:GetHandler()
	c:Type(TYPE_SPELL|TYPE_FIELD)
	Duel.MoveToField(c,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
	e1:SetCode(EVENT_LEAVE_FIELD_P)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetOperation(s.monster)
	e1:SetReset(RESET_EVENT|RESETS_STANDARD)
	c:RegisterEffect(e1,true)
end
function s.monster(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:Type(TYPE_MONSTER|TYPE_EFFECT)
end
function s.fldcost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.fldreveal,tp,LOCATION_GRAVE|LOCATION_DECK|LOCATION_HAND|LOCATION_FZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.fldreveal,tp,LOCATION_GRAVE|LOCATION_DECK|LOCATION_HAND|LOCATION_FZONE,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,g)
	g:RegisterFlagEffect(888,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	e:SetLabelObject(g:GetCardEffect(888):GetLabelObject())
end
function s.fldreveal(c,tp)
	return c:IsCode(58998106)
end
function s.fldtg(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=e:GetLabelObject()
	local tg=te and te:GetTarget() or nil
	if chkc then return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
	if chk==0 then return true end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	e:SetProperty(te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and EFFECT_FLAG_CARD_TARGET or 0)
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	e:SetLabelObject(te)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOHAND,nil,2,tp,LOCATION_GRAVE+LOCATION_DECK)
end
function s.fldflt(c)
	return c:IsCode(58998120) and c:IsAbleToHand()
end
function s.fldop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Apply Queen Ambrosé's effect
	local rc=Duel.GetFieldCard(tp,LOCATION_FZONE,0):GetOriginalAttribute()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and rc then
		s.operation(e,tp,eg,ep,ev,re,r,rp)
	end
	Duel.BreakEffect()
	--Add 2 "Horticopia Garden Harvest" from Deck or GY
	if not e:GetHandler():IsRelateToEffect(e) then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_ATOHAND)
	local g=Duel.SelectMatchingCard(tp,aux.NecroValleyFilter(s.fldflt),tp,LOCATION_GRAVE+LOCATION_DECK,0,2,2,nil)
	if #g>1 then
		Duel.SendtoHand(g,nil,REASON_EFFECT)
		Duel.ConfirmCards(1-tp,g)
	end
end
function s.operation(e,tp,eg,ep,ev,re,r,rp)
	local te=e:GetLabelObject()
	if not te then return end
	local sc=te:GetHandler()
	if sc:GetFlagEffect(888)==0 then
		e:SetLabel(0)
		e:SetLabelObject(nil)
		return
	end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	local op=te:GetOperation()
	if op then
		op(e,tp,Group.CreateGroup(),PLAYER_NONE,0,e,REASON_EFFECT,PLAYER_NONE)
	end
	e:SetLabel(0)
	e:SetLabelObject(nil)
end