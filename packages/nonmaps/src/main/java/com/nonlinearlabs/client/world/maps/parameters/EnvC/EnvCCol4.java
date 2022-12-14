package com.nonlinearlabs.client.world.maps.parameters.EnvC;

import com.nonlinearlabs.client.world.maps.MapsLayout;
import com.nonlinearlabs.client.world.maps.parameters.ModulateableKnob;
import com.nonlinearlabs.client.world.maps.parameters.ModulationSourceSlider;
import com.nonlinearlabs.client.world.maps.parameters.ParameterColumn;

class EnvCCol4 extends ParameterColumn {

	EnvCCol4(MapsLayout parent) {
		super(parent);
		addChild(new ModulateableKnob(this, 44));
		addChild(new ModulationSourceSlider(this, 426));
	}
}
