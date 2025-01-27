-- Queen Ambrosé of Horticopia
local s,id=GetID()
function s.initial_effect(c)
	c:Attribute(127)
	c:EnableReviveLimit()
	--Become a Field Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.smnop)
	c:RegisterEffect(e1)
	--Create "Harvest Token"
	local e2=Effect.CreateEffect(c)
	e2:SetDescription(aux.Stringid(id,1))
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN)
	e2:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_MOVE)
	e2:SetCountLimit(1,id)
	e2:SetCondition(function(e) return e:GetHandler():IsLocation(LOCATION_FZONE) and e:GetHandler():IsRitualSummoned() end)
	e2:SetTarget(s.target)
	e2:SetOperation(s.token)
	c:RegisterEffect(e2)
		local prop=EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_IGNORE_IMMUNE+EFFECT_FLAG_SET_AVAILABLE
		local e3=Effect.CreateEffect(c)
		e3:SetType(EFFECT_TYPE_SINGLE)
		e3:SetProperty(prop,EFFECT_FLAG2_MAJESTIC_MUST_COPY)
		e3:SetCode(888)
		e3:SetLabelObject(e2)
		e3:SetLabel(c:GetOriginalCode())
		if resetflag and resetcount then
			e3:SetReset(resetflag,resetcount)
			elseif resetflag then
			e3:SetReset(resetflag)
		end
		c:RegisterEffect(e3)
	--Unaffected by other effects
	local e4=Effect.CreateEffect(c)
	e4:SetType(EFFECT_TYPE_SINGLE)
	e4:SetProperty(EFFECT_FLAG_SINGLE_RANGE)
	e4:SetCondition(s.imncon)
	e4:SetCode(EFFECT_IMMUNE_EFFECT)
	e4:SetRange(LOCATION_FZONE)
	e4:SetValue(s.imnval)
	c:RegisterEffect(e4)
	--Win the Duel
	local e5=Effect.CreateEffect(c)
	e5:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_CONTINUOUS)
	e5:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_UNCOPYABLE)
	e5:SetCode(EVENT_ADJUST)
	e5:SetRange(LOCATION_FZONE)
	e5:SetOperation(s.winop)
	c:RegisterEffect(e5)
end
s.listed_names={58998122}
function s.target(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return not Duel.IsPlayerAffectedByEffect(tp,CARD_BLUEEYES_SPIRIT)
		and Duel.GetLocationCount(tp,LOCATION_MZONE)>0
		and s.attlmt(e,tp)~=0 end
	Duel.SetOperationInfo(0,CATEGORY_TOKEN,nil,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,0)
end
function s.attlmt(e,tp)
	local lmt=0
	for i=1,7 do
		local att=2^(i-1)
		if Duel.IsPlayerCanSpecialSummonMonster(tp,58998900+i,0,TYPES_TOKEN,0,0,1,RACE_PLANT,att)
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
		--DEF is equal to its Level
		local e4=Effect.CreateEffect(token)
		e4:SetDescription(aux.Stringid(id,4))
		e4:SetType(EFFECT_TYPE_SINGLE)
		e4:SetProperty(EFFECT_FLAG_CANNOT_DISABLE+EFFECT_FLAG_CLIENT_HINT)
		e4:SetCode(EFFECT_UPDATE_DEFENSE)
		e4:SetRange(LOCATION_MZONE)
		e4:SetValue(function (e,c) return c:GetLevel()*100 end)
		e4:SetReset(RESET_EVENT|RESETS_STANDARD)
		token:RegisterEffect(e4,true)
		Duel.SpecialSummonComplete()
		Duel.BreakEffect()
		--Increase lvls by 1
		local g=Duel.GetMatchingGroup(s.lvlflt,tp,LOCATION_MZONE,0,nil,token)
		local tc=g:GetFirst()
		for tc in aux.Next(g) do
			local e1=Effect.CreateEffect(c)
			e1:SetType(EFFECT_TYPE_SINGLE)
			e1:SetCode(EFFECT_UPDATE_LEVEL)
			e1:SetProperty(EFFECT_FLAG_CANNOT_DISABLE)
			e1:SetValue(1)
			e1:SetReset(RESET_EVENT+RESETS_STANDARD)
			tc:RegisterEffect(e1)
		end
	end
end
function s.lvlflt(c,token)
	return c:IsFaceup() and c:IsCode(58998901) and not (c:GetAttribute()==token:GetAttribute())
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
	local g=Duel.GetMatchingGroup(Card.IsCode,tp,LOCATION_MZONE,0,c,58998901)
	if  e:GetHandler():IsRitualSummoned() and g:GetSum(Card.GetLevel)>=100 then
		Duel.Win(tp,WIN_REASON_GHOSTRICK_MISCHIEF)
	end
end