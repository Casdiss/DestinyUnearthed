-- Horticopia Garden Harvest
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	c:RegisterEffect(e1)
end
s.listed_series={0x888}
function s.condition(e,tp)
	local fld=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fld then
		return fld:IsSetCard(0x888)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.fltreveal,tp,LOCATION_GRAVE|LOCATION_DECK|LOCATION_HAND|LOCATION_FZONE,0,1,nil,tp) end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_CONFIRM)
	local g=Duel.SelectMatchingCard(tp,s.fltreveal,tp,LOCATION_GRAVE|LOCATION_DECK|LOCATION_HAND|LOCATION_FZONE,0,1,1,nil,tp):GetFirst()
	Duel.ConfirmCards(1-tp,g)
	g:RegisterFlagEffect(888,RESET_EVENT|RESETS_STANDARD|RESET_CHAIN,0,1)
	e:SetLabelObject(g:GetCardEffect(888):GetLabelObject())
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
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
	local b1=Duel.IsExistingMatchingCard(s.fltsummon,tp,LOCATION_GRAVE|LOCATION_HAND,0,1,nil,e,tp)
	local b2=Duel.GetLocationCount(tp,LOCATION_MZONE)>0
	local op=Duel.SelectEffect(tp,
		{b1,aux.Stringid(id,0)},
		{b2,aux.Stringid(id,1)},
		{true,aux.Stringid(id,2)})
	e:SetLabel(op)
	if op==1 then
		Duel.ClearOperationInfo(0)
	elseif op==2 then
		Duel.ClearOperationInfo(0)
	elseif op==3 then
		e:SetCategory(CATEGORY_REMOVE)
		Duel.SetOperationInfo(0,CATEGORY_REMOVE,g,1,0,0)
	end
	Duel.SetChainLimit(aux.FALSE)
end
function s.fltsummon(c,e,tp)
	return c:IsSetCard(0x888) and c:IsMonster() and not c:IsForbidden()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	local op=e:GetLabel()
	if op==1 then
		--Place 1 "Horticopia" Monster from the hand or GY in the Field Zone
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
		e:SetLabel(0)
		e:SetLabelObject(nil)
	elseif op==2 then
		--Create 1 "Harvest Token" and increase lvls by 2
		s.operation(e,tp,eg,ep,ev,re,r,rp)
		e:SetLabel(0)
		e:SetLabelObject(nil)
		local g=Duel.GetMatchingGroup(s.lfilter,tp,LOCATION_MZONE,0,nil)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(2)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	elseif op==3 then
		--Tribute 1 "Harvest Token" and increase lvls by its lvl
		local g=Duel.GetMatchingGroup(s.lfilter2,tp,LOCATION_MZONE,0,nil)
		local c=e:GetHandler()
		local tc=g:GetFirst()
		local rg=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_MZONE,0,1,1,nil,e,tp)
		e:SetLabel(0)
		e:SetLabelObject(nil)
		if #rg>0 then 
			e:SetLabel(rg:GetFirst():GetLevel())
			Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
			for tc in aux.Next(g) do
				local e1=Effect.CreateEffect(c)
				e1:SetType(EFFECT_TYPE_SINGLE)
				e1:SetCode(EFFECT_UPDATE_LEVEL)
				e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
				e1:SetValue(e:GetLabel())
				e1:SetReset(RESET_EVENT+RESETS_STANDARD)
				tc:RegisterEffect(e1)
			end
		end
	end
end
function s.rfilter(c,e,tp)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
		and c:IsFaceup() and c:IsCode(58998901) 
end
function s.lfilter(c)
	return c:IsFaceup() and c:IsCode(58998901)
end
function s.lfilter2(c)
	return c:IsFaceup() and c:IsCode(58998901) and not (c:GetAttribute()==token:GetAttribute())
end
function s.fltreveal(c,tp)
	return c:IsCode(58998106)
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
end
function s.monster(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:Type(TYPE_MONSTER|TYPE_EFFECT)
end