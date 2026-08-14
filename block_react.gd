extends Node

class_name BlockReact

const Block_Data = {
	"sky": {"can_move": false},
	"solid_block": {"can_move": false},
	"brick": {"can_move": true, "distructable": ["big", "fire"], "transform_into": "brick"},
	"brick_secret": {"can_move": true, "have_secret": true, "transform_into": "secret_disactive"},
	"secret_active": {"can_move": true, "have_secret": true, "transform_into": "secret_disactive"},
	"secret_disactive": {"can_move": false},
	
	
}

func trigger_block(player_state: String, block_type: String, secret: String = "none"):
	if not Block_Data.has(block_type):
		return {"action": []}
	
	var block_info = Block_Data[block_type]
	
	if block_info["can_move"] == false:
		return {"action": []}
	
	elif "have_secret" in block_info:
		return {
			"action": ["bump", "secret"],
			"give": secret
		}
	
	elif player_state in block_info.get("distructable", []):
		return {"action": ["destroy"]}
	
	return {"action": ["bump"]}
	
		
