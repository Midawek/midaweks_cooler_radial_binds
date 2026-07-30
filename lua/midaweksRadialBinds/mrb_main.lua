-- MIDAWEK'S COOLER RADIAL BINDS

MCRB = MCRB or {}
MCRB.Vars = MCRB.Vars or {}


if CLIENT then
    MCRB.Vars.Styles = CreateClientConVar("mcrb_cl_radial_style", 0, true, false,
        "Change the style of how radial binds looks, refer to documentation for information", 0)
end
