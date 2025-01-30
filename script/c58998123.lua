-- Horticopia Moxidrupe
local s, id = GetID()
function s.initial_effect(c)
	--Negate the Summon and if you do, destroy it, then Summon a "Harvest Token"
	local e1=Effect.CreateEffect(c)
	e1:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN+CATEGORY_DISABLE_SUMMON+CATEGORY_DESTROY)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_SPSUMMON)
	e1:SetCondition(s.condition)
	e1:SetTarget(s.target)
	e1:SetOperation(s.token)
	c:RegisterEffect(e1)
end
function s.condition(e,tp,eg,ep,ev,re,r,rp)
	local fld=Duel.GetFieldCard(tp,LOCATION_FZONE,0)
	if not fld then return false end
	return fld:IsSetCard(0x888) and ep==1-tp and Duel.GetCurrentChain(true)==0
end
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(1-tp,LOCATION_MZONE)>0
		and Duel.IsPlayerCanSpecialSummonMonster(tp,58998909,0,TYPES_TOKEN,0,1000,0,RACE_PLANT,0)
	end
	Duel.SetOperationInfo(0,CATEGORY_DISABLE_SUMMON,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DESTROY,eg,#eg,0,0)
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.token(e,tp,eg,ep,ev,re,r,rp)
	--Negate the Summon and if you do, destroy it
	Duel.NegateSummon(eg)
	Duel.Destroy(eg,REASON_EFFECT)
	Duel.BreakEffect()
	--Summon "Harvest Token"
	local c=e:GetHandler()
	token=Duel.CreateToken(tp,58998909)
	Duel.SpecialSummonStep(token,0,tp,1-tp,false,false,POS_FACEUP_DEFENSE)
	--Cannot be tributed
	local e1=Effect.CreateEffect(token)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
	e1:SetCode(EFFECT_UNRELEASABLE_SUM)
	e1:SetValue(1)
	e1:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e1,true)
	local e2=e1:Clone()
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
	token:RegisterEffect(e2)
	--Cannot be used as material for a Fusion, Synchro, Xyz, or Link Summon
	local e3=Effect.CreateEffect(token)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetType(EFFECT_TYPE_SINGLE)
	e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
	e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
	e3:SetReset(RESET_EVENT|RESETS_STANDARD)
	token:RegisterEffect(e3,true)
	--Level is equal to the number of "Harvest Counters" on this card
	local e4=Effect.CreateEffect(token)
	e4:SetDescription(aux.Stringid(id,2))
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e4:SetCode(EFFECT_CHANGE_LEVEL)
	e4:SetRange(LOCATION_MZONE)
	e4:SetValue(function (e,c) return c:GetCounter(0x1888) end)
	e4:SetReset(RESET_EVENT|RESETS_STANDARD)
	token:RegisterEffect(e4,true)
	--DEF is equal to its Level
	local e5=Effect.CreateEffect(token)
	e5:SetDescription(aux.Stringid(id,3))
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
	e5:SetCode(EFFECT_UPDATE_DEFENSE)
	e5:SetRange(LOCATION_MZONE)
	e5:SetValue(function (e,c) return c:GetLevel()*100 end)
	e5:SetReset(RESET_EVENT|RESETS_STANDARD)
	token:RegisterEffect(e5,true)
	Duel.SpecialSummonComplete()
	token:AddCounter(0x1888,1)
	Duel.BreakEffect()
	--Cannot change its battle position
	local e6=Effect.CreateEffect(token)
	e6:SetDescription(3313)
	e6:SetProperty(EFFECT_FLAG_CLIENT_HINT)
	e6:SetType(EFFECT_TYPE_SINGLE)
	e6:SetCode(EFFECT_CANNOT_CHANGE_POSITION)
	e6:SetReset(RESET_EVENT+RESETS_STANDARD)
	token:RegisterEffect(e6,true)
	--Place 1 "Harvest Counter" on each "Harvest Token" with an attribute
	local g=Duel.GetMatchingGroup(s.lvlflt,tp,LOCATION_MZONE,0,nil,token)
	local tc=g:GetFirst()
	for tc in aux.Next(g) do
		tc:AddCounter(0x1888,1)
	end
end
function s.lvlflt(c,token)
	return c:IsFaceup() and c:IsCode(58998901) and not (c:GetAttribute()==0)
end