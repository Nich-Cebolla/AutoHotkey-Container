
class NlsVersionInfo {
    static __New() {
        this.DeleteProp('__New')
        proto := this.Prototype
        proto.cbSizeInstance :=
        ; Size    Type       Symbol                  OffsetPadding
        4 +       ; DWORD    dwNLSVersionInfoSize    0
        4 +       ; DWORD    dwNLSVersion            4
        4 +       ; DWORD    dwDefinedVersion        8
        4 +       ; DWORD    dwEffectiveId           12
        A_PtrSize ; GUID     guidCustomVersion       16
        proto.offset_dwNLSVersionInfoSize  := 0
        proto.offset_dwNLSVersion          := 4
        proto.offset_dwDefinedVersion      := 8
        proto.offset_dwEffectiveId         := 12
        proto.offset_guidCustomVersion     := 16
    }
    __New(dwNLSVersionInfoSize?, dwNLSVersion?, dwDefinedVersion?, dwEffectiveId?, guidCustomVersion?) {
        this.Buffer := Buffer(this.cbSizeInstance)
        if IsSet(dwNLSVersionInfoSize) {
            this.dwNLSVersionInfoSize := dwNLSVersionInfoSize
        }
        if IsSet(dwNLSVersion) {
            this.dwNLSVersion := dwNLSVersion
        }
        if IsSet(dwDefinedVersion) {
            this.dwDefinedVersion := dwDefinedVersion
        }
        if IsSet(dwEffectiveId) {
            this.dwEffectiveId := dwEffectiveId
        }
        if IsSet(guidCustomVersion) {
            this.guidCustomVersion := guidCustomVersion
        }
    }
    dwNLSVersionInfoSize {
        Get => NumGet(this.Buffer, this.offset_dwNLSVersionInfoSize, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwNLSVersionInfoSize)
        }
    }
    dwNLSVersion {
        Get => NumGet(this.Buffer, this.offset_dwNLSVersion, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwNLSVersion)
        }
    }
    dwDefinedVersion {
        Get => NumGet(this.Buffer, this.offset_dwDefinedVersion, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwDefinedVersion)
        }
    }
    dwEffectiveId {
        Get => NumGet(this.Buffer, this.offset_dwEffectiveId, 'uint')
        Set {
            NumPut('uint', Value, this.Buffer, this.offset_dwEffectiveId)
        }
    }
    guidCustomVersion {
        Get => NumGet(this.Buffer, this.offset_guidCustomVersion, 'ptr')
        Set {
            NumPut('ptr', Value, this.Buffer, this.offset_guidCustomVersion)
        }
    }
    Ptr => this.Buffer.Ptr
    Size => this.Buffer.Size
}
