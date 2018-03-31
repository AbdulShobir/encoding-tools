/// Encoding Tools
/// Copyright (C) 2018 Mark E. Haase
///
/// This program is free software: you can redistribute it and/or modify
/// it under the terms of the GNU Affero General Public License as published by
/// the Free Software Foundation, either version 3 of the License, or
/// (at your option) any later version.
///
/// This program is distributed in the hope that it will be useful,
/// but WITHOUT ANY WARRANTY; without even the implied warranty of
/// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
/// GNU Affero General Public License for more details.
///
/// You should have received a copy of the GNU Affero General Public License
/// along with this program.  If not, see <http://www.gnu.org/licenses/>.

import 'package:angular/angular.dart';

/// Base class for gadgets that implements some shared functionality.
class BaseGadget {
    /// When an input pipe changes, disconnect the consumer from the old
    /// pipe and attach it to the new pipe.
    void rewire(SimpleChange change, GadgetPipeConsumer consumer) {
        var prev = change.previousValue;
        if (prev != null) {
            prev.removeConsumer(consumer);
        }

        var curr = change.currentValue;
        if (curr != null) {
            curr.attachConsumer(consumer);
        }
    }

    /// If a pipe is non-null, then sends data over that pipe,
    void send(GadgetPipe output, List<int> data) {
        if (output != null) {
            output.send(data);
        }
    }
}

/// Metadata for a single gadget in the workspace.
class GadgetConfig {
    String type;
    List<GadgetPipe> inputs;
    List<GadgetPipe> outputs;

    GadgetConfig(this.type) {
        this.inputs = [];
        this.outputs = [];
    }
}

/// Broadcast one gadget's output to other gadgets' inputs.
///
/// Similar to Dart's Stream except simplified quite a bit. This simpler
/// functionality is easier to use.
class GadgetPipe {
    /// List of gadgets that consume data from this pipe.
    List<GadgetPipeConsumer> _consumers;

    /// Constructor.
    GadgetPipe() {
        this._consumers = [];
    }

    /// The producer calls this method to send data through the pipe.
    void send(List<int> data) {
        for (var consumer in this._consumers) {
            consumer(data);
        }
    }

    /// Attach a consumer to a pipe.
    void attachConsumer(GadgetPipeConsumer consumer) {
        if (this._consumers.contains(consumer)) {
            throw new Exception('This pipe is already attached to ${consumer}');
        }
        this._consumers.add(consumer);
    }

    /// Remove a consumer from a pipe.
    void removeConsumer(GadgetPipeConsumer consumer) {
        this._consumers.remove(consumer);
    }
}

/// Callback for pipe data event.
typedef void GadgetPipeConsumer(List<int> data);
