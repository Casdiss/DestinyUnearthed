-- Horticopia Crop Rotation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
function s.condition(e,tp)
	local fld=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fld then
		return fld:IsSetCard(0x888)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.fltbanish,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp)
		and Duel.IsExistingMatchingCard(s.fltreveal,tp,LOCATION_GRAVE|LOCATION_DECK|LOCATION_HAND|LOCATION_FZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g1=Duel.SelectMatchingCard(tp,s.fltbanish,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp)
	local g2=Duel.SelectMatchingCard(tp,s.fltreveal,tp,LOCATION_GRAVE|LOCATION_DECK|LOCATION_HAND|LOCATION_FZONE,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,g2)
	g2:RegisterFlagEffect(888,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	e:SetLabelObject(g2:GetCardEffect(888):GetLabelObject())
	Duel.Remove(g1,POS_FACEUP,REASON_COST)
end
function s.fltbanish(c,tp)
	return c:IsMonster() and c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.fltreveal(c,tp)
	return c:IsCode(58998106)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	local te=e:GetLabelObject()
	local tg=te and te:GetTarget() or nil
	if chkc then return tg and tg(e,tp,eg,ep,ev,re,r,rp,0,chkc) end
	if chk==0 then return Duel.IsExistingTarget(s.fltsummon,tp,LOCATION_GRAVE|LOCATION_HAND,0,1,nil,e,tp) end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	e:SetProperty(te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and EFFECT_FLAG_CARD_TARGET or 0)
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	e:SetLabelObject(te)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN,g,1,0,0)
end
function s.fltsummon(c,e,tp)
	return c:IsSetCard(0x888) and c:IsMonster() and not c:IsForbidden()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.fltsummon,tp,LOCATION_GRAVE|LOCATION_HAND,0,nil,e,tp)
	if #g>0 then
		Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_TOFIELD)
		local tc=g:Select(tp,1,1,nil):GetFirst()
		tc:Type(TYPE_SPELL|TYPE_FIELD)
		Duel.MoveToField(tc,tp,tp,LOCATION_FZONE,POS_FACEUP,true)
		local e1=Effect.CreateEffect(tc)
		e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_CONTINUOUS)
		e1:SetCode(EVENT_LEAVE_FIELD_P)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetOperation(s.monster)
		e1:SetReset(RESET_EVENT|RESETS_STANDARD)
		tc:RegisterEffect(e1,true)
	end
	local rc=Duel.GetFieldCard(tp,LOCATION_FZONE,0):GetOriginalAttribute()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and rc then
		local c=e:GetHandler()
		--Apply Queen Ambrosé's effect
		s.operation(e,tp,eg,ep,ev,re,r,rp)
	end
end
function s.monster(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:Type(TYPE_MONSTER|TYPE_EFFECT)
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