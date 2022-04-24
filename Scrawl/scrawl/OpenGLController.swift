//
//  OpenGLController.swift
//  scrawl
//
//  Created by Itghost Fan on 2022/4/18.
//

import UIKit
import GLKit

import SnapKit

class OpenGLController: UIViewController, GLKViewDelegate {
    
    static private let vertextSize = 3
    
    private var glkView = GLKView()
    private var glkBaseEffect = GLKBaseEffect()
    private var vertextBuffer = UnsafeMutablePointer<GLuint>.allocate(capacity: 1)
    private var vertices = UnsafeMutablePointer<GLKVector3>.allocate(capacity: vertextSize)

    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.view.addSubview(glkView)
        glkView.snp.makeConstraints { make in
            make.edges.equalTo(self.view)
        }
        
        vertices[0].x = -0.5
        vertices[0].y = -0.5
        vertices[0].z = 0.0
        vertices[1].x = 0.5
        vertices[1].y = -0.5
        vertices[1].z = 0.0
        vertices[2].x = -0.5
        vertices[2].y = 0.5
        vertices[2].z = 0.0
        
        glkView.context = EAGLContext(api: .openGLES2)!
        glkView.delegate = self
        EAGLContext.setCurrent(glkView.context)
        
        glkBaseEffect.useConstantColor = GLboolean(GL_TRUE)
        glkBaseEffect.constantColor = GLKVector4(v: (1.0, 1.0, 1.0, 1.0))
        glClearColor(0.0, 0.0, 0.0, 1.0)
        
        print("Before Vertext Buffer Is \(vertextBuffer[0])")
        glGenBuffers(GLsizei(1), vertextBuffer)
        print("After Vertext Buffer Is \(vertextBuffer[0])")
        glBindBuffer(GLenum(GL_ARRAY_BUFFER), vertextBuffer[0])
        glBufferData(GLenum(GL_ARRAY_BUFFER), MemoryLayout<GLKVector3>.size * OpenGLController.vertextSize, vertices, GLenum(GL_STATIC_DRAW))
    }
    
    deinit {
        EAGLContext.setCurrent(nil)
        glDeleteBuffers(GLsizei(1), vertextBuffer)
        vertices.deallocate()
        vertextBuffer.deallocate()
    }
    
    // MARK: GLKViewDelegate
    
    func glkView(_ view: GLKView, drawIn rect: CGRect) {
        glkBaseEffect.prepareToDraw()
        glClear(GLbitfield(GL_COLOR_BUFFER_BIT))
        glEnableVertexAttribArray(GLuint(GLKVertexAttrib.position.rawValue))
        glVertexAttribPointer(GLuint(GLKVertexAttrib.position.rawValue), GLint(OpenGLController.vertextSize), GLenum(GL_FLOAT), GLboolean(GL_FALSE), GLsizei(MemoryLayout<GLKVector3>.size), UnsafeRawPointer(nil))
        glDrawArrays(GLenum(GL_TRIANGLES), GLint(0), GLsizei(OpenGLController.vertextSize))
    }

}
