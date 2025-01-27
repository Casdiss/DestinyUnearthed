-- Horticopia-Wildrosera
local s, id = GetID()
function s.initial_effect(c)
	c:Attribute(63)
	c:EnableReviveLimit()
  	--Become a Field Spell
	local e1=Effect.CreateEffect(c)
	e1:SetDescription(aux.Stringid(id,0))
	e1:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_F)
	e1:SetCode(EVENT_SPSUMMON_SUCCESS)
	e1:SetOperation(s.smnop)
	c:RegisterEffect(e1)
	--Apply Queen Ambrosé's effect, then draw 2 cards
	local e3=Effect.CreateEffect(c)
	e3:SetDescription(aux.Stringid(id,1))
	e3:SetCategory(CATEGORY_DRAW)
	e3:SetType(EFFECT_TYPE_SINGLE+EFFECT_TYPE_TRIGGER_O)
	e3:SetProperty(EFFECT_FLAG_DELAY)
	e3:SetCode(EVENT_MOVE)
	e3:SetCountLimit(1,id)
	e3:SetCondition(function(e) return e:GetHandler():IsLocation(LOCATION_FZONE) and e:GetHandler():IsRitualSummoned() end)
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
	if chk==0 then return Duel.IsPlayerCanDraw(tp,2) end
	e:SetLabel(te:GetLabel())
	e:SetLabelObject(te:GetLabelObject())
	e:SetProperty(te:IsHasProperty(EFFECT_FLAG_CARD_TARGET) and EFFECT_FLAG_CARD_TARGET or 0)
	if tg then
		tg(e,tp,eg,ep,ev,re,r,rp,1)
	end
	e:SetLabelObject(te)
	Duel.SetTargetPlayer(tp)
	Duel.SetTargetParam(3)
	Duel.SetOperationInfo(0,CATEGORY_SPECIAL_SUMMON+CATEGORY_TOKEN,g,1,0,0)
	Duel.SetOperationInfo(0,CATEGORY_DRAW,nil,0,tp,3)
	Duel.SetOperationInfo(0,CATEGORY_HANDES,nil,0,tp,1)
end
function s.fldop(e,tp,eg,ep,ev,re,r,rp)
	local c=e:GetHandler()
	--Apply Queen Ambrosé's effect
	local rc=Duel.GetFieldCard(tp,LOCATION_FZONE,0):GetOriginalAttribute()
	if Duel.GetLocationCount(tp,LOCATION_MZONE)>0 and rc then
		s.operation(e,tp,eg,ep,ev,re,r,rp)
	end
	Duel.BreakEffect()
	--Draw 2 cards, then discard 1
	local p=Duel.GetChainInfo(0,CHAININFO_TARGET_PLAYER)
	if Duel.Draw(p,3,REASON_EFFECT)==3 then
		Duel.ShuffleHand(tp)
		Duel.BreakEffect()
		Duel.DiscardHand(tp,nil,1,1,REASON_EFFECT+REASON_DISCARD)
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