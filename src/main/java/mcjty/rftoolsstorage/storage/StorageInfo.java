package mcjty.rftoolsstorage.storage;

import java.util.Objects;
import java.util.UUID;

public class StorageInfo {

    public static final StorageInfo EMPTY = new StorageInfo(null, -1, 0);

    private final UUID uuid;
    private final int version;
    private final int size;

    public StorageInfo(UUID uuid, int version, int size) {
        this.uuid = uuid;
        this.version = version;
        this.size = size;
    }

    public UUID getUuid() {
        return uuid;
    }

    public int getVersion() {
        return version;
    }

    public int getSize() {
        return size;
    }

    public boolean isEmpty() {
        return uuid == null;
    }

    @Override
    public boolean equals(Object o) {
        if (this == o) return true;
        if (o == null || getClass() != o.getClass()) return false;
        StorageInfo that = (StorageInfo) o;
        return version == that.version &&
                size == that.size &&
                Objects.equals(uuid, that.uuid);
    }

    @Override
    public int hashCode() {
        return Objects.hash(uuid, version, size);
    }
}
