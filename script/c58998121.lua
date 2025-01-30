-- Horticopia Crop Rotation
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	e1:SetCondition(s.condition)
	e1:SetProperty(EFFECT_FLAG_CARD_TARGET)
	e1:SetCost(s.cost)
	e1:SetTarget(s.target)
	e1:SetOperation(s.activate)
	e1:SetLabelObject(e1)
	c:RegisterEffect(e1)
	--Ritual
	local e2=Ritual.CreateProc({handler=c,lvtype=RITPROC_GREATER,filter=aux.FilterBoolFunction(Card.IsSetCard,0x888)})
	e2:SetType(EFFECT_TYPE_QUICK_O)
	e2:SetRange(LOCATION_GRAVE)
	e2:SetCost(s.gycost)
	c:RegisterEffect(e2)

end
function s.condition(e,tp)
	local fld=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if fld then
		return fld:IsSetCard(0x888)
	end
end
function s.cost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return Duel.IsExistingMatchingCard(s.fltbanish,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,nil,tp) end
	local g=Duel.SelectMatchingCard(tp,s.fltbanish,tp,LOCATION_MZONE|LOCATION_GRAVE,0,1,1,nil,tp)
	Duel.Remove(g,POS_FACEUP,REASON_COST)
end
function s.fltbanish(c,tp)
	return c:IsMonster() and c:IsRace(RACE_PLANT) and c:IsAbleToRemoveAsCost() and aux.SpElimFilter(c,true)
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk,chkc)
	if chk==0 then return Duel.IsExistingTarget(s.fltsummon,tp,LOCATION_GRAVE|LOCATION_HAND,0,1,nil,e,tp) end
end
function s.fltsummon(c,e,tp)
	return c:IsSetCard(0x888) and c:IsMonster() and not c:IsForbidden()
end
function s.activate(e,tp,eg,ep,ev,re,r,rp)
	Duel.Activate(e:GetLabelObject())
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
end
function s.monster(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	c:Type(TYPE_MONSTER|TYPE_EFFECT)
end
function s.gycost(e,tp,eg,ep,ev,re,r,rp,chk)
	local c=e:GetHandler()
	if chk==0 then return c:IsAbleToRemoveAsCost()
		and  Duel.IsExistingMatchingCard(s.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,nil,e,tp) end
	local rg=Duel.SelectMatchingCard(tp,s.rfilter,tp,LOCATION_MZONE,LOCATION_MZONE,1,1,nil,e,tp)
	Duel.Remove(c,POS_FACEUP,REASON_COST)
	Duel.Remove(rg,POS_FACEUP,REASON_EFFECT)
end
function s.rfilter(c,e,tp)
	return c:IsAbleToRemove() and not c:IsImmuneToEffect(e)
		and c:IsFaceup() and c:IsCode(58998901) and c:IsOwner(tp)
end