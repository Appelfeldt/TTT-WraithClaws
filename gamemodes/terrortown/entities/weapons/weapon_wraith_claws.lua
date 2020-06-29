AddCSLuaFile()

-- First some standard GMod stuff
if SERVER then
   util.AddNetworkString("ttt_wraith_attack2")
end

if CLIENT then
   SWEP.PrintName = "Wraith Claws"
   SWEP.Slot      = 8 -- add 1 to get the slot number key

   SWEP.ViewModelFOV  = 72
   SWEP.ViewModelFlip = true
end

-- Always derive from weapon_tttbase.
SWEP.Base = "weapon_tttbase"
DEFINE_BASECLASS(SWEP.Base)
--- Standard GMod values

SWEP.Primary.Damage = 30
SWEP.Primary.ClipSize = 100
SWEP.Primary.DefaultClip = 100
SWEP.Primary.Automatic = true
SWEP.Primary.Delay = 0.6
SWEP.Primary.Ammo = "fade"
SWEP.Primary.Sound = Sound( "Weapon_Crowbar.Single" )

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true
-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = true
-- If LimitedStock is true, you can only buy one per round.
SWEP.LimitedStock = true

SWEP.Secondary.Delay = 0.5

SWEP.UseHands = true
SWEP.ViewModel = Model("models/weapons/cstrike/c_knife_t.mdl")
SWEP.WorldModel = Model("models/weapons/w_knife_t.mdl")
SWEP.HoldType = "knife"

local str_wraith_fade = "ttt_wraith_fade"
local str_wraith_fade_tick = "ttt_wraith_fade_tick"
local str_wraith_leap_ready = "ttt_wraith_leap_ready"
local str_wraith_grab = "ttt_wraith_grab"
local str_wraith_grab_ready = "ttt_wraith_grab_ready"
local str_wraith_grabbing = "ttt_wraith_grabbing"
local str_wraith_owner = "ttt_wraith_owner"

--- TTT config values

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_EQUIP2

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2, then this gun can
-- be spawned as a random weapon. Of course this AK is special equipment so it won't,
-- but for the sake of example this is explicitly set to false anyway.
-- SWEP.AutoSpawnable = false

-- The AmmoEnt is the ammo entity that can be picked up when carrying this gun.
-- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
-- a role is in this table, those players can buy this.
SWEP.CanBuy = { ROLE_VAMPIRE, ROLE_KILLER }

-- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
-- receive this weapon as soon as the round starts. In this case, none.
SWEP.InLoadoutFor = nil

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

-- Equipment menu information is only needed on the client
if CLIENT then
   -- Path to the icon material
   SWEP.Icon = "VGUI/ttt/icon_knife"

   -- Text shown in the equip menu
   SWEP.EquipMenuData = {
      type = "Weapon",
      desc = [[While this weapon has energy it makes you nearly invisible, take no fall damage and able to leap.

Primary is a melee attack, kills with it replenish your energy.

Secondary cause you to leap. While leaping, aim at a wall and hold jump to wallgrab. You can perform a leap from a wallgrab.]]
   };
end

-- Tell the server that it should download our icon to clients.
if SERVER then
   -- It's important to give your icon a unique name. GMod does NOT check for
   -- file differences, it only looks at the name. This means that if you have
   -- an icon_ak47, and another server also has one, then players might see the
   -- other server's dumb icon. Avoid this by using a unique name.
   --resource.AddFile("materials/VGUI/ttt/icon_knife.vmt")
end

local sound_single = Sound("Weapon_Crowbar.Single")

local init = false;
function SWEP:Initialize()
   self.init = true;

   if CLIENT then
   end

   if SERVER then
   end
end

local help_text = { text = "", font = "TabLarge", xalign = TEXT_ALIGN_CENTER}

local help_general = "This weapon make you nearly invisible, take no fall damage and able to leap, but only if it has energy."
local help_primary = "Your primary is a melee attack, kills with it replenish your energy."
local help_secondary = "Your secondary cause you to leap. While leaping, aim at walls while holding jump to wallgrab. You can leap again after grabbing a wall."

function SWEP:DrawHelp()
      help_text.pos  = {ScrW() / 2.0, ScrH() - 80}
      help_text.text = help_general
      draw.TextShadow(help_text, 2)
      
      help_text.pos  = {ScrW() / 2.0, ScrH() - 60}
      help_text.text = help_primary
      draw.TextShadow(help_text, 2)
      
      help_text.pos  = {ScrW() / 2.0, ScrH() - 40}
      help_text.text = help_secondary
      draw.TextShadow(help_text, 2)
      
      help_text.pos  = {ScrW() / 2.0, ScrH() - 40}
      help_text.text = help_secondary
      draw.TextShadow(help_text, 2)
end

function SWEP:PrimaryAttack()
   self.Weapon:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
   

   if not IsValid(self:GetOwner()) then return end
   if self:GetOwner().LagCompensation then -- for some reason not always true
      self:GetOwner():LagCompensation(true)
   end
   
   local spos = self:GetOwner():GetShootPos()
   local sdest = spos + (self:GetOwner():GetAimVector() * 120)
   
   tr_main = util.TraceHull( {
      start = self:GetOwner():GetShootPos(),
      endpos = self:GetOwner():GetShootPos() + ( self:GetOwner():GetAimVector() * 100 ),
      filter = self:GetOwner(),
      mins = Vector( -10, -10, -10 ),
      maxs = Vector( 10, 10, 10 )
   } )
   local hitEnt = tr_main.Entity
   
   self.Weapon:EmitSound(sound_single)
   
   if IsValid(hitEnt) or tr_main.HitWorld then
      if not (CLIENT and (not IsFirstTimePredicted())) then
         local edata = EffectData()
         edata:SetStart(spos)
         edata:SetOrigin(tr_main.HitPos)
         edata:SetNormal(tr_main.Normal)
         edata:SetSurfaceProp(tr_main.SurfaceProps)
         edata:SetHitBox(tr_main.HitBox)
         edata:SetEntity(hitEnt)
         
         if hitEnt:IsPlayer() or hitEnt:GetClass() == "prop_ragdoll" then
            util.Effect("BloodImpact", edata)
            self:GetOwner():LagCompensation(false)
            self:GetOwner():FireBullets({ Num = 1, Src = spos, Dir = self:GetOwner():GetAimVector(), Spread = Vector(0, 0, 0), Tracer = 0, Force = 1, Damage = 0 })
         else
            util.Effect("Impact", edata)
         end
      end
   end
   self.Weapon:SendWeaponAnim(ACT_VM_MISSCENTER)
   
   if SERVER then
      self:GetOwner():SetAnimation(PLAYER_ATTACK1)
      
      if hitEnt and hitEnt:IsValid() then
         local dmg = DamageInfo()
         dmg:SetDamage(self.Primary.Damage)
         dmg:SetAttacker(self:GetOwner())
         dmg:SetInflictor(self.Weapon or self)
         dmg:SetDamageForce(self:GetOwner():GetAimVector() * 10000)
         dmg:SetDamagePosition(self:GetOwner():GetPos())
         dmg:SetDamageType(128)
         if hitEnt:IsPlayer() then
             if hitEnt:Health() <= self.Primary.Damage and not hitEnt:IsJester() and not hitEnt:IsSwapper() and not self:GetOwner():IsJester() and not self:GetOwner():IsSwapper() then
               self:SetClip1(math.min(self:Clip1() + 40, 100))
               self:Fade(0.1)
            end
         end
         hitEnt:DispatchTraceAttack(dmg, tr_main, sdest)
      end
   end

   if CLIENT then
      self:GetOwner():SetAnimation(PLAYER_ATTACK1)
   end
   
   if self:GetOwner().LagCompensation then
      self:GetOwner():LagCompensation(false)
   end
end

function SWEP:SecondaryAttack()
   if self:GetNextSecondaryFire() > CurTime() 
      or self:Clip1() <= 0
      or not self:GetOwner():GetNWBool(str_wraith_leap_ready) then
      return
   end
   
   self.Weapon:SetNextSecondaryFire(CurTime() + self.Secondary.Delay)
   if SERVER then
      self:Leap()
   end
end

function SWEP:Equip(newOwner)
   if SERVER then
      self:SetVar(str_wraith_owner, newOwner)
      self:GetOwner():SetVar(str_wraith_fade, 1.0)
      self:GetOwner():SetNWBool(str_wraith_leap_ready, false)
      self:GetOwner():SetNWBool(str_wraith_grab, false)
      self:GetOwner():SetNWBool(str_wraith_grab_ready, false)
      self:GetOwner():SetNWBool(str_wraith_grabbing, false)
      self:GetOwner():SetNWFloat(str_wraith_fade_tick, CurTime())
   end
end

function SWEP:OnDrop()
   if SERVER then
      local owner = self:GetVar(str_wraith_owner, nil)
      if owner != nil then
         owner:SetMaterial("")
         owner:SetRenderMode(RENDERMODE_NORMAL)
         owner:SetColor(Color(255, 255, 255, 255))
         self:SetVar(str_wraith_owner, nil)
         if owner:GetVar(str_wraith_fade, 1.0)  != 1.0 then
            owner:EmitSound("weapons/ttt/unfade.wav")
         end
      end
   end
end

function SWEP:Deploy()
   
   self:SetHoldType(self.HoldType)

   if SERVER then
      if self:Clip1() > 0 then
         self:Fade(0.1)
         self:GetOwner():SetNWBool(str_wraith_leap_ready, self:IsOnGround()) --Check for ground
         self:GetOwner():SetNWBool(str_wraith_grab, false)
         self:GetOwner():SetNWBool(str_wraith_grab_ready, false)
         self:GetOwner():EmitSound("weapons/ttt/fade.wav")
      end
   end
end

function SWEP:Holster(weapon)
   if ( IsFirstTimePredicted() ) then
   end

   if SERVER then
      self:Fade(1.0)
      self:GetOwner():SetNWBool(str_wraith_leap_ready, false)
      self:GetOwner():SetNWBool(str_wraith_grab, false)
      self:GetOwner():SetNWBool(str_wraith_grab_ready, false)
      self:GetOwner():SetNWBool(str_wraith_grabbing, false)
      self:GetOwner():SetMoveType(MOVETYPE_WALK)
      if self:Clip1() > 0 then
         self:GetOwner():EmitSound("weapons/ttt/unfade.wav")
      end
   end

   return true
end

function SWEP:DrawWorldModel()
   if !self:GetOwner():IsPlayer() then
      self:DrawModel()
   end
end

function SWEP:Think()
   if not self.init then return end

   if self:Clip1() <= 0 then
      self:Fade(1.0)
      return
   end

   self:Client_HandleInput()
   self:Server_Validate()
   if CLIENT then return end

   if CurTime() >= self:GetOwner():GetVar(str_wraith_fade_tick, 0) + 1 then
      self:GetOwner():SetVar(str_wraith_fade_tick, CurTime())
      
      self:SetClip1(self:Clip1()-1)
   end
end

if (SERVER) then
    local function nofalldam(target, dmginfo)    
        if (dmginfo:IsFallDamage() and target:GetActiveWeapon():GetClass() == "weapon_wraith_claws" and target:GetActiveWeapon():Clip1() > 0) then
            dmginfo:SetDamage(0)
            return dmginfo
        end
    end
    hook.Add("EntityTakeDamage", "donotfalldamage", nofalldam)

    local function removeFade()
      local players = player:GetAll()
      print(util.TypeToString(players))
      for _,p in pairs(players) do
         print(util.TypeToString(p))
         p:SetVar(str_wraith_fade, 1.0)
         p:SetMaterial("")
         p:SetRenderMode(RENDERMODE_NORMAL)
         p:SetColor(Color(255, 255, 255, 255))
      end
    end
    hook.Add("TTTPrepareRound", "removeFade", removeFade)
end


function SWEP:Client_HandleInput()
   if not CLIENT then return end

   local jump = input.GetKeyCode(input.LookupBinding("+jump"))

   if input.IsButtonDown(jump) 
   and self:GetOwner():GetNWBool(str_wraith_grab_ready, false) 
   and not self:GetOwner():GetNWBool(str_wraith_grab, true) then
      net.Start("ttt_wraith_attack2")
      net.WriteBool(true)
      net.SendToServer()
      self:GetOwner():SetNWBool(str_wraith_grab, true)
   elseif not input.IsButtonDown(jump) and self:GetOwner():GetNWBool(str_wraith_grab, false) then
      net.Start("ttt_wraith_attack2")
      net.WriteBool(false)
      net.SendToServer()
      self:GetOwner():SetNWBool(str_wraith_grab, false)
   end

end


function SWEP:Server_Validate()
   if not SERVER then return end

   self:WallGrab()

   if not self:GetOwner():GetNWBool(str_wraith_leap_ready, false) and self:GetOwner():IsOnGround() then
      self:GetOwner():SetNWBool(str_wraith_leap_ready, true)
      self:GetOwner():SetNWBool(str_wraith_grab_ready, false)
      self:GetOwner():SetNWBool(str_wraith_grab, false)
      self:GetOwner():SetNWBool(str_wraith_grabbing, false)
      self:GetOwner():SetMoveType(MOVETYPE_WALK)
   end
end


function SWEP:Fade(percentage)
   if not SERVER then return end

      self:GetOwner():SetVar(str_wraith_fade, percentage)
      if percentage >= 1.0 then
         self:GetOwner():SetMaterial("")
         self:GetOwner():SetRenderMode(RENDERMODE_NORMAL)
         self:GetOwner():SetColor(Color(255, 255, 255, 255))
      elseif percentage >= 0.0 then
         self:GetOwner():SetMaterial("sprites/heatwave")
         self:GetOwner():SetRenderMode(RENDERMODE_TRANSCOLOR)
         self:GetOwner():SetColor(Color(0, 0, 0, percentage*255))
      end
end



function SWEP:Leap()
   if not self:GetOwner():IsOnGround() and not self:GetOwner():GetNWBool(str_wraith_grabbing, false) then return end
   self:GetOwner():SetVelocity(self:GetOwner():GetAimVector() * 800 + Vector(0, 0, 1) * 300)
   if self:GetOwner():GetNWBool(str_wraith_grabbing, false) then
      self:GetOwner():SetNWBool(str_wraith_grabbing, false)
      self:GetOwner():SetMoveType(MOVETYPE_WALK)
   end
   self:GetOwner():SetNWBool(str_wraith_leap_ready, false)
   self:GetOwner():SetNWBool(str_wraith_grab_ready, true)
end


function SWEP:WallGrab()
   if not SERVER then return end

   if self:GetOwner():GetNWBool(str_wraith_grabbing, false) 
   and not self:GetOwner():GetNWBool(str_wraith_grab, false) then
      self:GetOwner():SetMoveType(MOVETYPE_WALK)
      --self:GetOwner():SetNWBool(str_wraith_grab_ready, false)
      self:GetOwner():SetNWBool(str_wraith_grab, false)
      self:GetOwner():SetNWBool(str_wraith_grabbing, false)
      self:GetOwner():SetNWBool(str_wraith_leap_ready, false)
   elseif self:GetOwner():GetNWBool(str_wraith_grab, false)
   and not self:GetOwner():GetNWBool(str_wraith_grabbing, false) then
      local v_pos = self:GetOwner():GetPos() + self:GetOwner():OBBCenter()
      local n_dir = self:GetOwner():GetAimVector()
      local n_fwd = Vector(n_dir.x, n_dir.y, 0):GetNormalized()

      local tr = util.TraceHull( {
         start = v_pos,
         endpos = v_pos + n_dir * 30,
         filter = self:GetOwner(),
         mins = Vector( -10, -10, -10 ),
         maxs = Vector( 10, 10, 10 )
      } )
      
      if tr.HitWorld then
         self:GetOwner():SetVelocity(self:GetOwner():GetVelocity()*-1)
         self:GetOwner():SetMoveType(MOVETYPE_NONE)
         self:GetOwner():SetNWBool(str_wraith_grabbing, true)
         self:GetOwner():SetNWBool(str_wraith_leap_ready, true)
      end
   end

end

if SERVER then
   net.Receive( "ttt_wraith_attack2", function( len, ply )
      local state = net.ReadBool()

      if ply:GetNWBool(str_wraith_grab_ready, false) then
         ply:SetNWBool(str_wraith_grab, state)
      end
   end)
end




























