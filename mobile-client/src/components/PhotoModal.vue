<template>
  <modal animationType="slide" :transparent="false" :visible="opened" :onRequestClose="close">
    <nb-header>
      <nb-left>
      </nb-left>
      <nb-body>
        <nb-title>Take Photo</nb-title>
      </nb-body>
      <nb-right>
        <nb-button transparent :onPress="close">
          <nb-text>Close</nb-text>
        </nb-button>
      </nb-right>
    </nb-header>

    <view :style="{ flex: 1, width: viewWidth, height: viewHeight }">
      <camera ref="camera" :style="{ flex: 1 }" :type="type">
        <view :style="{flex: 1, backgroundColor: 'transparent',flexDirection: 'column'}">
          <touchable-opacity :style="{flex: 2, alignSelf: 'flex-end'}"
            :onPress="() => type = type === cameraConstants.Type.back ? cameraConstants.Type.front : cameraConstants.Type.back">
            <text :style="{ marginTop: 10, marginRight: 20 }">
              <nb-icon :style="{fontSize: 34, color: 'white'}" active name="reverse-camera" />
            </text>
          </touchable-opacity>
          <touchable-opacity :style="{flex: 2, alignSelf: 'center', justifyContent: 'flex-end'}"
            :onPress="takePicture">
            <view :style="{ flex: 0, flexDirection: 'column', alignSelf: 'flex-end', marginBottom: 30 }">
              <nb-icon :style="{fontSize: 50, color: 'white'}" active name="camera" />
            </view>
          </touchable-opacity>
        </view>
      </camera>
    </View>

  </modal>
</template>

<script>
import { Dimensions, Modal } from "react-native";
import { Camera, Permissions } from "expo";

const deviceWidth = Dimensions.get("window").width;
const deviceHeight = Dimensions.get("window").height;

export default {
  name:'photo-modal',
  components: {
    Modal,
    Camera
  },
  data: function() {
    return {
      viewWidth: deviceWidth,
      viewHeight: deviceHeight - 64,
      hasCameraPermission: false,
      type: Camera.Constants.Type.back,
      cameraConstants: Camera.Constants
    }
  },
  props: {
    newPhoto: {
      type: Object
    },
    closeNewPhoto: {
      type: Function
    }
  },
  computed: {
    opened () {
      return this.newPhoto.opened
    },
  },
  methods: {
    close () {
      this.closeNewPhoto()
    },
    takePicture: async function() {
      if (this.$refs.camera) {
        let photo = await this.$refs.camera.takePictureAsync({quality: 0.5});
        this.closeNewPhoto(photo)
      }
    },
  },
  mounted () {
    var vm = this
    Permissions.askAsync(Permissions.CAMERA)
     .then(status => {
       this.hasCameraPermission = status.status == "granted" ? true : false;
     }).catch((err)=>{
        console.log(err);
     });
  }
}
</script>

 
<style>

</style>
