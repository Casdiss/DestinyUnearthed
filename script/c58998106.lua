-- Queen Ambrosé of Horticopia
local s,id=GetID()
function s.initial_effect(c)
	c:Attribute(127)
	c:EnableReviveLimit()
	Fusion.AddProcMixN(c,true,true,58998108,1,aux.FilterBoolFunctionEx(Card.IsSetCard,0x888),2)
	--Must be Fusion Summoned
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_SINGLE)
	e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e1:SetCode(EFFECT_SPSUMMON_CONDITION)
	e1:SetValue(aux.fuslimit)
	c:RegisterEffect(e1)
	--Become a Field Spell
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,0))
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e2:SetCode(EVENT_SPSUMMON_SUCCESS)
	e2:SetOperation(s.smnop)
	c:RegisterEffect(e2)
	--Create "Harvest Token"
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_MOVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e) return e:GetHandler():IsLocation(LOCATION_FZONE) end)
	e3:SetTarget(s.target)
	e3:SetOperation(s.token)
	c:RegisterEffect(e3)
		local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
		local e4=Effect.CreateEffect(c)
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
		e4:SetCode(888)
		e4:SetLabelObject(e3)
		e4:SetLabel(c:GetOriginalCode())
		if resetflag and resetcount then
			e4:SetReset(resetflag,resetcount)
			elseif resetflag then
			e4:SetReset(resetflag)
		end
		c:RegisterEffect(e4)
	--Unaffected by other effects
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_SINGLE)
	e5:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e5:SetCondition(s.imncon)
	e5:SetCode(EFFECT_IMMUNE_EFFECT)
	e5:SetRange(LOCATION_FZONE)
	e5:SetValue(s.imnval)
	c:RegisterEffect(e5)
	--Win the Duel
	local e6=Effect.CreateEffect(c)
	e6:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e6:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e6:SetCode(EVENT_ADJUST)
	e6:SetRange(LOCATION_FZONE)
	e6:SetOperation(s.winop)
	c:RegisterEffect(e6)
end
s.listed_names={58998122}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and s.attlmt(e,tp)~=0 end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.attlmt(e,tp)
	local lmt=0
	for i=1,7 do
		local att=2^(i-1)
		if Duel.IsPlayerCanSpecialSummonMonster(tp,58998900+i,0,TYPES_TOKEN,0,1000,0,RACE_PLANT,att)
			then lmt=lmt+att
		end
	end
	return lmt
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
function s.token(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	local fc=Duel.IsExistingMatchingCard(Card.IsSetCard,tp,LOCATION_FZONE,0,1,nil,0x888)
	if fc then
		local rc=Duel.GetFieldCard(tp,LOCATION_FZONE,0):GetOriginalAttribute()
		local token=Duel.CreateToken(tp,58998901+math.log(rc,2))
		if rc==127 then
			token=Duel.CreateToken(tp,58998908)
		elseif rc==63 then
			token=Duel.CreateToken(tp,58998907)
		end
		Duel.SpecialSummonStep(token,0,tp,tp,false,false,POS_FACEUP_DEFENSE)
		--Cannot be tributed execpt by "Horticopia" cards
		local e1=Effect.CreateEffect(token)
		e1:SetType(EFFECT_TYPE_SINGLE)
		e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
		e1:SetCode(EFFECT_UNRELEASABLE_SUM)
		e1:SetValue(1)
		e1:SetReset(RESET_EVENT+RESETS_STANDARD)
		token:RegisterEffect(e1,true)
		local e2=e1:Clone()
		e2:SetDescription(aux.Stringid(id,2))
		e2:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e2:SetCode(EFFECT_UNRELEASABLE_NONSUM)
		token:RegisterEffect(e2)
		--Cannot be used as material for a Fusion, Synchro, Xyz, or Link Summon
		local e3=Effect.CreateEffect(token)
		e3:SetDescription(aux.Stringid(id,3))
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e3:SetCode(EFFECT_CANNOT_BE_MATERIAL)
		e3:SetValue(aux.cannotmatfilter(SUMMON_TYPE_FUSION,SUMMON_TYPE_SYNCHRO,SUMMON_TYPE_XYZ,SUMMON_TYPE_LINK))
		e3:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e3,true)
		--Level is equal to the number of "Harvest Counters"
		local e4=Effect.CreateEffect(token)
		e4:SetDescription(aux.Stringid(id,4))
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e4:SetCode(EFFECT_CHANGE_LEVEL)
		e4:SetRange(LOCATION_MZONE)
		e4:SetValue(function (e,c) return c:GetCounter(0x1888) end)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e4,true)
		--DEF is equal to its Level
		local e5=Effect.CreateEffect(token)
		e5:SetDescription(aux.Stringid(id,5))
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
		--Place 1 "Harvest Counter" on each "Harvest Token" with a differnt attribute
		local g=Duel.GetMatchingGroup(s.lvlflt,tp,LOCATION_MZONE,LOCATION_MZONE,nil,token,tp)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			tc:AddCounter(0x1888,1)
		end
	end
end
function s.lvlflt(c,token,tp)
	return c:IsFaceup() and c:IsCode(58998901) and c:IsOwner(tp) and not (c:GetAttribute()==token:GetAttribute())
end
function s.sumval(e,c)
	return not c:IsSetCard(0x888)
end
function s.imncon(e)
	local tp=e:GetHandler():GetOwner()
	return Duel.IsExistingMatchingCard(s.imnflt,tp,LOCATION_MZONE,0,1,nil)
end
function s.imnflt(c)
	return c:IsFaceup() and c:IsCode(58998901)
end
function s.imnval(e,te)
	return not te:GetOwner():IsSetCard(0x888)
end
function s.winop(e,tp,eg,ep,ev,re,r,rp)
	local g=Duel.GetMatchingGroup(s.winflt,tp,LOCATION_MZONE,LOCATION_MZONE,c,tp)
	if  e:GetHandler():IsFusionSummoned() and g:GetSum(Card.GetCounter(0x1888))>=100 then
		Duel.Win(tp,WIN_REASON_GHOSTRICK_MISCHIEF)
	end
end
function s.winflt(c,tp)
	return c:IsCode(58998901) and c:IsOwner(tp)
end