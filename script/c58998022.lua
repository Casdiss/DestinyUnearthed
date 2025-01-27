--Sustainium Mines
local s,id=GetID()
function s.initial_effect(c)
	--Activate
	local e1=Effect.CreateEffect(c)
	e1:SetType(EFFECT_TYPE_ACTIVATE)
	e1:SetCode(EVENT_FREE_CHAIN)
	c:RegisterEffect(e1)
	--Special Summon 1 level 5 or higher Rock Tunner monster from your hand
	local e2=Effect.CreateEffect(c)
	e2:SetCategory(CATEGORY_SPECIAL_SUMMON)
	e2:SetType(EFFECT_TYPE_FIELD+EFFECT_TYPE_TRIGGER_O)
	e2:SetProperty(EFFECT_FLAG_DELAY)
	e2:SetCode(EVENT_TO_HAND)
	e2:SetRange(LOCATION_FZONE)
	e2:SetCountLimit(1,0,EFFECT_COUNT_CODE_CHAIN)
	e2:SetCondition(s.spcon)
	e2:SetTarget(s.sptg)
	e2:SetOperation(s.spop)
	c:RegisterEffect(e2)
	--Attach 1 level 5 or higher Rock Tunner monster from your hand
	local e3=e2:Clone()
	e3:SetCategory(0)
	e3:SetCountLimit(1,1,EFFECT_COUNT_CODE_CHAIN)
	e3:SetCondition(s.atcon)
	e3:SetTarget(s.attg)
	e3:SetOperation(s.atop)
	c:RegisterEffect(e3)
end
function s.spcon(_,tp,eg)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	local lvs=g:GetSum(Card.GetLevel)
	local rks=g:GetSum(Card.GetRank)
	return eg:IsExists(s.confilter,1,nil,tp) and rks>lvs
end
function s.confilter(c,tp)
	return c:IsControler(tp) and c:IsLevelAbove(5) and c:IsRace(RACE_ROCK) and c:IsType(TYPE_TUNER)
	and not c:IsReason(REASON_DRAW)
end
function s.sptg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.spfilter,tp,LOCATION_HAND|LOCATION_MZONE,0,1,nil) end
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON,nil,1,tp,LOCATION_HAND|LOCATION_MZONE)
end
function s.spfilter(c)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ROCK) and c:IsType(TYPE_TUNER) and c:IsSummonable(true,nil)
end
function s.spop(e,tp,eg,ep,ev,re,r,rp)
	if Duel.GetLocationCount(tp,LOCATION_MZONE)<=0 then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_SPSUMMON)
	local g=Duel.SelectMatchingCard(tp,s.spfilter,tp,LOCATION_HAND,0,1,1,nil,e,tp)
	if #g>0 then
		Duel.SpecialSummon(g,0,tp,tp,false,false,POS_FACEUP)
	end
end
function s.atcon(_,tp,eg)
	local g=Duel.GetMatchingGroup(Card.IsFaceup,tp,LOCATION_MZONE,0,c)
	local lvs=g:GetSum(Card.GetLevel)
	local rks=g:GetSum(Card.GetRank)
	return eg:IsExists(s.confilter,1,nil,tp) and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil)
		and rks<lvs 
end
function s.atfilter(c,e)
	return c:IsLevelAbove(5) and c:IsRace(RACE_ROCK) and c:IsType(TYPE_TUNER) and not c:IsImmuneToEffect(e)
end
function s.xyzfilter(c)
	return c:IsFaceup() and c:IsType(TYPE_XYZ)
end
function s.attg(e,tp,eg,ep,ev,re,r,rp,chk)
	if chk==0 then return Duel.IsExistingMatchingCard(s.atfilter,tp,LOCATION_HAND,0,1,nil,e)
		and Duel.IsExistingMatchingCard(s.xyzfilter,tp,LOCATION_MZONE,0,1,nil,e) end
end
function s.atop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	if not c:IsRelateToEffect(e) or c:IsFacedown() then return end
	Duel.Hint(HINT_SELECTMSG,tp,HINTMSG_XMATERIAL)
	local tc=Duel.SelectMatchingCard(tp,s.atfilter,tp,LOCATION_HAND,0,1,1,nil,e):GetFirst()
	local xyz=Duel.SelectMatchingCard(tp,s.xyzfilter,tp,LOCATION_MZONE,0,1,1,nil,e):GetFirst()
	if tc then
		Duel.Overlay(xyz,tc,true)
	end
end